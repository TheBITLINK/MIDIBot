youtubedl = require 'youtube-dl'
fs = require 'fs'
child_process = require 'child_process'

class VideoToWav
  constructor: (@engine, @msg, @nameOrUrl, @filename)->
    {@bot} = @engine
    @path = './data/tmp/'+@filename+'.webm'
    @wavPath = './data/tmp/'+@filename+'.wav'

  beginConvert: (@cb)=>
    @bot.startTyping @msg.channel
    @dl =  youtubedl @nameOrUrl,
                     ['--default-search', 'ytsearch', '-f', 'bestaudio'],
                     { cwd: __dirname }
    @dl.on 'info', @onInfo
    @dl.pipe fs.createWriteStream @path
    @dl.on 'end', @onEnd
    @dl.on 'error', @onError

  onInfo: (@info)=>
    @bot.reply @msg, 'Converting **' + @info.title + '** to MIDI... Be patient... '
    @bot.stopTyping @msg.channel
  
  onEnd: ()=>
    cb = @cb
    msg = @msg
    path = @path
    wavPath = @wavPath
    wavConvert = this
    fs.exists @path, (exists)->
      cb(false, msg) if not exists
      ffmpeg = child_process.spawn 'ffmpeg', ['-i', path, wavPath]
      ffmpeg.on 'exit', (err)->cb(err isnt 0, msg, wavConvert)

  onError: (error)=>
    console.error error
    @cb true, @msg

  deleteFiles: ()=>
    fs.unlink @path
    fs.unlink @wavPath

module.exports = VideoToWav