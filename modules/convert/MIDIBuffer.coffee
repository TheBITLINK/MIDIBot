###
# Here's where the magic happens
###
{ spawn } = require 'child_process'
EventEmitter = require 'events'

class MIDIBuffer extends EventEmitter
  constructor: (@path)->
    @internalBuffer = null
    b = []
    ffToWav = spawn 'ffmpeg', [
      '-i', @path
      '-f', 'wav'
      '-'
    ]
    WavToMidi = spawn "#{__dirname}/waon", [
      '-i', '-'
      '-o', '-'
    ]
    ffToWav.stdout.pipe(WavToMidi.stdin)
    WavToMidi.stdout.on 'data', (d)=>
      b.push d
    WavToMidi.stdout.on 'end', =>
      @emit 'done', @internalBuffer = Buffer.concat(b)

  getWavStream: =>
    return null if not @internalBuffer
    midiToWav = spawn 'timidity', [
      '-OwlS', '-'
      '-o', '-'
    ]
    midiToWav.stdin.write(@internalBuffer)
    return midiToWav.stdout
    
module.exports = MIDIBuffer
