###
THIS IS WHERE THE REAL MAGIC HAPPENS ¯\_(ツ)_/¯
###
Chance = require 'chance'
VideoToWav = require './videoToWav'
WavToMidi = require './wavToMIDI'

class ConvertModule
  constructor: (@engine)->
    {@bot,@commands} = @engine
    # Convert Command!
    commandOptions =
      description: 'Converts a song to midi'
      argExplain: '<url or title>'
    @convertCommand = @commands.registerCommand 'convert', commandOptions, @convertFunc
    
  convertFunc: (msg,args)=>
    return @bot.reply msg 'No video specified' if not args.trim()
    chance = new Chance()
    fname = chance.string {length: 6, pool: 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'}
    wav = new VideoToWav @engine, msg, args, fname
    wav.beginConvert(@convertCallback1)
  
  convertCallback1: (error, msg, convert)=>
    if error
      convert.deleteFiles()
      return @bot.reply(msg, 'There was an error while trying to convert to MIDI.')
    midi = new WavToMidi @engine, msg, convert.wavPath, convert.filename, convert
    midi.beginConvert @convertCallback2

  convertCallback2: (error, msg, convert)=>
    if error
      convert.wavConvert.deleteFiles()
      convert.deleteFiles()
      return @bot.reply(msg, 'There was an error while trying to convert to MIDI.')
    convert.wavConvert.deleteFiles()
    @bot.sendFile msg.channel,
                  convert.midiPath,
                  convert.filename+".mid",
                  msg.author.mention() + ", enjoy your high quality MIDI file!",
                  (err, m)->
                    @bot.reply msg "Couldnt send the MIDI file, check if the bot has permission to send files." if err
                    convert.deleteFiles()

  shutdown: ()=>
    @commands.unregisterCommand 'convert'
    

module.exports = ConvertModule
