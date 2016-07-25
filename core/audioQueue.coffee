class ServerAudioQueue
  constructor: (@engine, @server)->
    {@bot, @permissions} = @engine
    {@audioPlayer} = @engine.serverData.servers[@server.id]
    @items = []

  addToQueue: (item)=>
    if item.path and item.playInChannel and typeof item.emit is 'function'
      @items.push(item)
      item.emit 'addedToQueue', @server
      if not @currentItem?
        @nextItem()

  nextItem: ()=>
    q = @
    if @currentItem?
      @currentItem.emit 'skipped'
      @currentItem.skipped = true
      @audioPlayer.stop()
    item = @items.shift()
    @currentItem = item
    return false if not @currentItem?
    @audioPlayer.play @currentItem.playInChannel, @currentItem.path, (error, stream)->
      if not error
        stream.on 'end', ()->
          q.audioPlayer.clean()
          q.nextItem() if not item.skipped
          item.emit 'end'    
        item.emit 'start'        
    true

  clearQueue: ()=>
    for item in @items
      @items.shift()
      item.emit 'skipped'
      item.skipped = true
    if @currentItem?
      @currentItem.emit 'skipped'
      @currentItem.skipped = true
      @currentItem = null
    @audioPlayer.stop()

module.exports = ServerAudioQueue
