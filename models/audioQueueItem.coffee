EventEmitter = require 'events';

class QueueItem extends EventEmitter
  constructor: (data)->
    {
       @title,
       @duration,
       @requestedBy,
       @playInChannel,
       @path,
    } = data

module.exports = QueueItem
