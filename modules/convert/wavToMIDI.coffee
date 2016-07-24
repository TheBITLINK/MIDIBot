fs = require 'fs'
child_process = require 'child_process'

class WavToMidi
  constructor: (@engine, @msg, @path, @filename, @wavConvert)->
    {@bot} = @engine
    @midiPath = './data/tmp/'+@filename+'.mid'

  beginConvert: (@cb)=>
    cb = @cb
    msg = @msg
    path = @path
    midiPath = @midiPath
    midiConvert = this
    fs.exists @path, (exists)->
      cb(false, msg) if not exists
      waon = child_process.spawn 'waon', ['-i', path, '-o', midiPath]
      waon.on 'exit', (err)->cb(err isnt 0, msg, midiConvert)

  deleteFiles: ()=>
    fs.unlink @midiPath

module.exports = WavToMidi
