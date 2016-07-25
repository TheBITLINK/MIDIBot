async = require 'async'

class ServerAudioPlayer
  constructor: (@engine, @server)->
    {@bot, @permissions} = @engine
    @volume = 0.5

  play: (audioChannel, path, callback)=>
    {bot, engine, server} = @
    player = @
    if @currentStream?
      return callback { message: 'Bot is currently playing another file on the server.' }
    async.waterfall [
        (cb)->player.join audioChannel, cb
        (connection, cb)->connection.playFile path, {}, cb
        (stream, cb)->
          stream.on 'end', ()->
            setTimeout ()->
              player.clean()
            , 1000
          player.currentStream = stream
          cb null, stream
    ], callback
    
  join: (audioChannel, cb)=>
    player = @
    if @voiceConnection?
      if @voiceConnection.voiceChannel.id isnt audioChannel.id
        return cb { message: 'Bot is already in another voice channel' } if @currentStream?
        @clean true
      else
        return cb null, @voiceConnection
    @bot.joinVoiceChannel audioChannel, (err, con)->
      return eb err if err?
      player.voiceConnection = con
      con.setVolume player.volume
      cb null, con

  setVolume: (@volume)=>@voiceConnection.setVolume @volume
  stop:   ()=>
    @voiceConnection.stopPlaying()
    @clean()
  pause:  ()=> @voiceConnection.pause()
  resume: ()=> @voiceConnection.resume()

  clean: (disconnect)=>
    @currentStream = null
    if disconnect
      @voiceConnection.destroy()
      @voiceConnection = null

module.exports = ServerAudioPlayer
