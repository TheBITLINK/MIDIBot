###
The Song Player
###
Chance = require 'chance'
VideoToWav = require '../convert/videoToWav'
WavToMidi = require '../convert/wavToMIDI'
MidiToWav = require '../convert/midiToWav'
QueueItem = require '../../models/audioQueueItem'

class PlayerModule
  constructor: (@engine)->
    {@bot, @commands, @permissions} = @engine
    # Play Command
    playOptions =
      description: 'Adds a song to the queue. (You need to be in a voice channel)'
    @playCommand = @commands.registerCommand 'play', playOptions, @playFunc
    # Skip Command
    skipOptions =
      description: 'Skips currently playing MIDI.'
      adminOnly: true
    @skipCommand = @commands.registerCommand 'skip', skipOptions, @skipFunc
    # Stop Command
    stopOptions =
      description: 'Stops the currently playin MIDI and clears the Queue.'
      adminOnly: true
    @stopCommand = @commands.registerCommand 'stop', stopOptions, @stopFunc
    # Pause Command
    pauseOptions =
      description: 'Pauses currently playing MIDI.'
      adminOnly: true
    @pauseCommand = @commands.registerCommand 'pause', pauseOptions, @pauseFunc
    # Resume Command
    resumeOptions =
      description: 'Resumes MIDI playback.'
      adminOnly: true
    @resumeCommand = @commands.registerCommand 'resume', resumeOptions, @resumeFunc
    # Volume Command
    volumeOptions =
      description: 'Sets the volume'
      #adminOnly: true
    @volumeCommand = @commands.registerCommand 'volume', volumeOptions, @volumeFunc

# Commands
  playFunc: (msg, args)=>
    {converting} = @getServerData(msg.server)
    return @bot.reply msg, 'No video specified.' if not args.trim()
    return @bot.reply msg, 'You must be in a voice channel to request MIDIs.' if not msg.author.voiceChannel
    return @bot.reply msg, "There's an ongoing conversion from this server, try again after that conversion is complete!" if converting
    @bot.reply msg, 'Your request has been received. **Please be patient**, converting to MIDI requires a *lot* of processing power (seriously!), so it might take from 30 seconds up to several minutes depending of how much conversions are being made at the same time and the length of the song.'
    chance = new Chance()
    fname = chance.string {length: 6, pool: 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'}
    wav = new VideoToWav @engine, msg, args, fname
    wav.beginConvert(@convertCallback1)

  skipFunc: (msg)=>
    {queue} = @getServerData(msg.server)
    if queue.items.length or queue.currentItem
      @bot.sendMessage msg.channel, "**#{msg.author.username}** skipped the current midi."
      queue.nextItem()
    else
      @bot.sendMessage msg.channel, "No MIDIs playing on the current server."
      
  stopFunc: (msg)=>
    {queue} = @getServerData(msg.server)
    if queue.currentItem
      queue.clearQueue()
      @bot.sendMessage msg.channel, "**#{msg.author.username}** cleared the queue."
    else
      @bot.sendMessage msg.channel, "No MIDIs playing on the current server."

  pauseFunc: (msg)=>
    {audioPlayer} = @getServerData(msg.server)
    if audioPlayer.currentStream
      audioPlayer.pause()
      @bot.sendMessage msg.channel, "**#{msg.author.username}** paused midi playback."
    else
      @bot.sendMessage msg.channel, "Nothing to pause."

  resumeFunc: (msg)=>
    {audioPlayer} = @getServerData(msg.server)
    if audioPlayer.currentStream
      audioPlayer.resume()
      @bot.sendMessage msg.channel, "**#{msg.author.username}** resumed midi playback."
    else
      @bot.sendMessage msg.channel, "Nothing to resume."

  volumeFunc: (msg, args)=>
    {audioPlayer} = @getServerData(msg.server)
    if not args
      return @bot.sendMessage msg.channel, "Current Volume: #{audioPlayer.volume*100}."
    limit = 100
    limit = 200 if @permissions.isAdmin msg.author
    limit = 500 if @permissions.isOwner msg.author
    volume = parseInt(args)
    if volume > 0 and volume <= limit
      audioPlayer.setVolume volume/100
      @bot.sendMessage msg.channel, "**#{msg.author.username}** set the volume to #{volume}."
    else
      @bot.sendMessage msg.channel, "Invalid volume provided."

# Callbacks
  convertCallback1: (error, msg, convert)=>
    if error
      convert.deleteFiles()
      return @bot.reply msg, 'There was an error while trying to convert to MIDI.'
    midi = new WavToMidi @engine, msg, convert.wavPath, convert.filename, convert
    midi.beginConvert @convertCallback2

  convertCallback2: (error, msg, convert)=>
    convert.wavConvert.deleteFiles()
    if error
      convert.deleteFiles()
      return @bot.reply msg, 'There was an error while trying to convert to MIDI.'
    wav = new MidiToWav @engine, msg, convert.midiPath, convert.filename, convert
    wav.beginConvert @convertCallback3
    
  convertCallback3: (error, msg, convert)=>
    m = @
    {queue, audioPlayer} = @getServerData(msg.server)
    convert.midiConvert.deleteFiles()
    if error
      convert.deleteFiles()
      return @bot.reply msg, 'There was an error while trying to convert to MIDI.'
    convert.moveFiles "./data/servers/#{msg.server.id}/queue/#{convert.filename}.wav", (err)->
      if not msg.author.voiceChannel or err
        return m.bot.reply msg, 'There was an error while trying to convert to MIDI.'

      qI = new QueueItem {
        title: convert.midiConvert.wavConvert.info.title
        duration: convert.midiConvert.wavConvert.info.duration
        requestedBy: msg.author
        playInChannel: msg.author.voiceChannel
        path: convert.wavPath
      }

      qI.on 'start', ()->
        m.bot.sendMessage msg.channel, """
          **Now Playing In** `#{qI.playInChannel.name}`:
          ```#{qI.title}```
          (Length: `#{qI.duration}` - Requested By #{qI.requestedBy.mention()})
          """
        
      qI.on 'end', ()->
        convert.deleteFiles()
        if not queue.items.length and not qI.skipped
          m.bot.sendMessage msg.channel, 'Nothing more to play.'
          audioPlayer.clean true

      m.bot.sendMessage msg.channel, "**#{msg.author}** added `#{qI.title}` (#{qI.duration}) to the queue! (Position \##{queue.items.length+1})"

      queue.addToQueue qI
    true

# Utillity Functions
  getServerData: (server)=> @engine.serverData.servers[server.id]

  shutdown: =>
    @commands.unregisterCommands [@playCommand]

module.exports = PlayerModule
