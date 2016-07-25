fs = require 'fs'
child_process = require 'child_process'

class MidiToWav
  constructor: (@engine, @msg, @path, @filename, @midiConvert)->
    {@bot} = @engine
    @wavPath = './data/tmp/'+@filename+'.wav'

  beginConvert: (@cb)=>
    data = @getServerData(@msg.server)
    {cb, msg, path, wavPath} = @
    wavConvert = @
    fs.exists @path, (exists)->
      return cb(false, msg) if not exists
      data.converting = true
      timidity = child_process.spawn 'timidity', ['-OwlS', path, '-o', wavPath]
      timidity.on 'exit', (err)->
        cb(err isnt 0, msg, wavConvert)
        data.converting = false

  deleteFiles: ()=>
    fs.unlink @wavPath

  moveFiles: (newPath, cb)=>
    wavConvert = @
    fs.rename @wavPath, newPath, (err)->
      return cb err if err
      wavConvert.wavPath = newPath
      cb null

  getServerData: (server)=> @engine.serverData.servers[server.id]


module.exports = MidiToWav
