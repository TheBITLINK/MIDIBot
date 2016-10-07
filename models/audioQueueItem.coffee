EventEmitter = require 'events'
moment = require 'moment'

class QueueItem extends EventEmitter
  constructor: (data)->
    {
       @title,
       @duration,
       @requestedBy,
       @playInChannel,
       @midiBuffer,
    } = data
    @voteSkip = []
    @originalDuration = @duration
    

module.exports = QueueItem
