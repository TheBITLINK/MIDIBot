Chance = require 'chance'

class GuildAudioQueueManager
  constructor: (@engine, @guild)->
    {@bot, @permissions, @getGuildData} = @engine
    {@audioPlayer} = @getGuildData @guild
    @items = []

  addToQueue: (item)=>
    if item.midiBuffer and item.playInChannel and typeof item.emit is 'function'
      @items.push(item)
      item.emit 'addedToQueue', @server
      if not @currentItem?
        @nextItem()

  nextItem: =>
    if @currentItem?
      @currentItem.emit 'skipped'
      @currentItem.emit 'end'
      @currentItem.skipped = true
      @audioPlayer.stop()
    item = @items.shift()
    @currentItem = item
    return false if not @currentItem?
    @playItem()

  playItem: (item=@currentItem)=>
    @audioPlayer.play item.playInChannel, item.midiBuffer
    .then (stream)=>
      stream.on 'end', ()=>
        @nextItem() if not item.skipped
        item.emit 'end'
      item.emit 'start'
    .catch (err)=>
      console.error err
      item.emit 'error', err
    true

  undo: =>
    last = @items.pop()
    return @nextItem() if not last and @currentItem
    last.skipped = true
    last.undone = true
    last.emit 'undone'
    last.emit 'end'

  remove: (index)=>
    return 'invalid' if not isFinite index or index >= @items.length
    item = @items.splice index, 1
    item.skipped = true
    item.undone = true
    item.emit 'undone'
    item.emit 'end'

  swap: (ix1, ix2)=>
    item1 = @items[ix1]
    @items[ix1] = @items[ix2]
    @items[ix2] = item1
    [ @items[ix1], @items[ix2] ]

  shuffle: => @items = new Chance().shuffle(@items)

  clearQueue: =>
    for item in @items
      @items.shift()
      item.emit 'skipped'
      item.skipped = true
    if @currentItem?
      @currentItem.skipped = true
      @currentItem.emit 'skipped'
      @currentItem.emit 'end'
      @currentItem = null
    @audioPlayer.stop()

module.exports = GuildAudioQueueManager
