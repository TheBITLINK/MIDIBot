###
THIS IS WHERE THE REAL MAGIC HAPPENS ¯\_(ツ)_/¯
###
Chance = require 'chance'
VideoToWav = require './videoToWav'

class ConvertModule
  constructor: (@engine)->
    {@bot,@commands} = @engine
    # Convert Command!
    commandOptions =
      description: 'Converts a song to midi'
      argExplain: '<url or title>'
    @convertCommand = @commands.registerCommand 'convert', commandOptions, @convertFunc
    
  convertFunc: (msg,args)=>
    chance = new Chance
    fname = chance.string {length: 6, pool: 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'}
    wav = new VideoToWav @engine, msg, args, fname
    wav.beginConvert(@convertCallback1)
  
  convertCallback1: (error, msg)=>
    return @bot.reply(msg, 'There was an error while trying to convert to MIDI.') if error

  shutdown: ()=>
    @commands.unregisterCommand 'convert'
    

module.exports = ConvertModule
