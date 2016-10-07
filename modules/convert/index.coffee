reload = require('require-reload')(require)
MIDIBuffer = reload './MIDIBuffer'
VideoUtils = reload '../player/VideoUtils'

class ConvertModule extends BotModule
  init: =>  
    @registerCommand 'convert', (msg, args)->
      d = @engine.getGuildData(msg.guild)
      return msg.reply 'No video specified' if not args.trim()
      return msg.reply "There's an ongoing conversion from this server, try again after that conversion is complete!" if d.converting
      VideoUtils.getInfo args
      .then (info)=>
        console.log info
        d.converting = true
        msg.reply "Converting `#{info.title}` to MIDI... **please be patient**..."
        conversion = new MIDIBuffer info.url
        conversion.on 'done', (buffer)=>
          d.converting = false
          msg.channel.uploadFile buffer, "#{info.title}.mid", "#{msg.author.mention} here's your high quality MIDI file:"

module.exports = ConvertModule
