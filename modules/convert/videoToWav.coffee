youtubedl = require 'youtube-dl'
fs = require 'fs'

class VideoToWav
  constructor: (@engine, @msg, @nameOrUrl, @filename)->
    {@bot} = @engine
    @path = './data/tmp/'+@filename+'.wav'

  beginConvert: (@cb)=>
    @dl =  youtubedl @nameOrUrl,
                     ['--default-search=ytsearch', '-f=bestaudio', '-x', '--audio-format=wav'],
                     { cwd: __dirname + '/data/tmp' }
    @dl.on 'info', @onInfo
    @dl.pipe fs.createWriteStream @path
    @dl.on 'end', @onEnd

  onInfo: (@info)=>
    @bot.reply @msg 'Converting **' + info.title + '** to MIDI... Be patient... '
  
  onEnd: ()=>
    cb = @cb
    fs.exists @path, (exists)->cb(not exists, @msg)

  deleteFile: ()=>
    fs.unlink @path

module.exports = VideoToWav