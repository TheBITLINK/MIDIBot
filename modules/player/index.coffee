QueueItem = require '../../models/audioQueueItem'
moment = require 'moment'
reload = require('require-reload')(require)
AudioModuleCommands = reload './commands'
AudioHud = reload './hud'
VideoUtils = reload './VideoUtils'
MIDIBuffer = reload '../convert/MIDIBuffer'

class PlayerModule extends BotModule
  init: =>
    { @permissions, @getGuildData } = @engine
    @hud = new AudioHud @
    @moduleCommands = new AudioModuleCommands @

  handleVideoInfo: (info, msg, args)=>
    d = @getGuildData(msg.guild)
    d.converting = true
    # Check if duration is valid
    duration = VideoUtils.parseTime info.duration
       
    if (duration > 1800 and not @permissions.isOwner(msg.author))
      return msg.reply 'The requested song is too long.'

    return if not isFinite(duration)

    omsg = null

    msg.reply "Converting `#{info.title}` to MIDI... **please be patient**..."
    .then (m)=> omsg = m

    b = new MIDIBuffer(info.url)

    b.once 'done', =>    
      {queue, audioPlayer} = d
      d.converting = false
      # Create a new queue item
      qI = new QueueItem {
        title: info.title
        duration
        requestedBy: msg.member
        playInChannel: msg.member.getVoiceChannel()
        midiBuffer: b
      }
      # Set events
      durationstr = if isFinite(qI.duration) then moment.utc(qI.duration * 1000).format("HH:mm:ss") else '∞'
      qI.once 'start', =>
        if omsg
          omsg.delete()
          omsg = null
        msg.channel.sendMessage @hud.nowPlaying msg.guild, qI, true
          .then (m)=>
            setTimeout (->m.delete()), 15000
    
      qI.once 'end', =>
        setTimeout (()=>
          if not queue.items.length and not queue.currentItem
            msg.channel.sendMessage 'Nothing more to play.'
            .then (m)=>
              setTimeout (->m.delete()), 15000
            audioPlayer.clean true
        ), 100
      
      msg.channel.sendMessage @hud.addItem msg.guild, qI.requestedBy, qI, queue.items.length+1
      .then (m)=>
        if omsg
          omsg.delete()
          omsg = m;
        setTimeout ->
          if omsg
            omsg.delete()
            omsg = null
        , 15000
        msg.delete()
      queue.addToQueue qI

module.exports = PlayerModule
