youtubedl = require 'youtube-dl'
fs = require 'fs'
child_process = require 'child_process'
moment = require 'moment'
pad = require 'pad-left'

class VideoToWav
  constructor: (@engine, @msg, @nameOrUrl, @filename)->
    {@bot} = @engine
    @path = './data/tmp/'+@filename+'.webm'
    @wavPath = './data/tmp/'+@filename+'.wav'

  beginConvert: (@cb)=>
    data = @getServerData @msg.server
    data.converting = true
    youtubedl.getInfo @nameOrUrl, ['--default-search', 'ytsearch', '-f', 'bestaudio'], @onInfo

  # Parse duration
  parseDuration: (durationStr)-> 
    d = durationStr.split ':'
    "#{d[0]}:#{pad d[1], 2, '0'}"

  onInfo: (err, @info)=>
    data = @getServerData @msg.server
    if err
      @cb err, @msg
      data.converting = false
      return
    # Someone has to do it :'(
    @info.duration = @parseDuration @info.duration
    duration = moment.duration(@info.duration).asSeconds()/60
    if duration > 600 or duration <= 0
      @bot.reply @msg, "You can't convert videos greater than 10 minutes on length!"
      data.converting = false
      return
    @bot.reply @msg, 'Converting **' + @info.title + '** to MIDI... Be patient... '
    @bot.stopTyping @msg.channel
    @dl =  youtubedl @nameOrUrl,
                     ['--default-search', 'ytsearch', '-f', 'bestaudio'],
                     { cwd: __dirname }
    @dl.pipe fs.createWriteStream @path
    @dl.on 'end', @onEnd
    @dl.on 'error', @onError
  
  onEnd: ()=>
    {cb, msg, path, wavPath} = @
    data = @getServerData @msg.server
    wavConvert = @
    fs.exists @path, (exists)->
      data.converting = false
      return cb(false, msg) if not exists
      data.converting = true
      ffmpeg = child_process.spawn 'ffmpeg', ['-i', path, wavPath]
      ffmpeg.on 'exit', (err)->
        cb(err isnt 0, msg, wavConvert)
        data.converting = false

  onError: (error)=>
    console.error error
    data.converting = false
    @cb true, @msg

  deleteFiles: ()=>
    fs.unlink @path
    fs.unlink @wavPath

  getServerData: (server)=> @engine.serverData.servers[server.id]

module.exports = VideoToWav