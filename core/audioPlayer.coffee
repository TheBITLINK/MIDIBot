util = require 'util' 

class GuildAudioPlayer
  constructor: (@engine, @guild)->
    {@bot, @permissions} = @engine
    @volume = 50

  play: (audioChannel, midiBuffer)=> new Promise (resolve, reject)=>
    if @currentStream?
      return reject { message: 'Bot is currently playing another file on the server.' }
    
    @join audioChannel
    .then (connection)=>
      connection.createExternalEncoder {
        type: 'ffmpeg'
        source: '-'
        format: 'pcm'
        frameDuration: 60
        outputArgs: ['-af', 'volume=2']
      }
    .then (@currentStream)=>
      midiBuffer.getWavStream().pipe(@currentStream.stdin)
      @encStream = @currentStream.play()
      @encStream.resetTimestamp()
      @voiceConnection.getEncoder().setVolume @volume
      @currentStream.on 'end', =>
        @clean()
      resolve @currentStream
    .catch (error)=>
      reject error
    
  join: (audioChannel)=> new Promise (resolve, reject)=>
    if @voiceConnection?
      if @voiceConnection.channelId isnt audioChannel.id
        return reject { message: 'Bot is already in another voice channel' } if @currentStream?
        @clean true
      else
        return resolve @voiceConnection
    audioChannel.join()
    .then (voiceConnectionInfo)=>
      { @voiceConnection } = voiceConnectionInfo
      resolve @voiceConnection
    .catch (error)=>
      reject error

  setVolume: (@volume)=> @voiceConnection.getEncoder().setVolume @volume
  stop:   ()=>
    try
      @currentStream.stop()
      # @currentStream.destroy()
    @clean()

  getTimestamp: => @encStream.timestamp

  clean: (disconnect)=>
    delete @currentStream
    delete @encStream
    try
      if disconnect
        @voiceConnection.disconnect()
        delete @voiceConnection

module.exports = GuildAudioPlayer
