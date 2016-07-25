fs = require 'fs'
child_process = require 'child_process'

class WavToMidi
  constructor: (@engine, @msg, @path, @filename, @wavConvert)->
    {@bot} = @engine
    @midiPath = './data/tmp/'+@filename+'.mid'

  beginConvert: (@cb)=>
    data = @getServerData(@msg.server)
    {cb, msg, path, midiPath} = @
    midiConvert = @
    fs.exists @path, (exists)->
      return cb(false, msg) if not exists
      data.converting = true
      waon = child_process.spawn 'waon', ['-i', path, '-o', midiPath]
      waon.on 'exit', (err)->
        cb(err isnt 0, msg, midiConvert)
        data.converting = false

  deleteFiles: ()=>
    fs.unlink @midiPath

  getServerData: (server)=> @engine.serverData.servers[server.id]

module.exports = WavToMidi
