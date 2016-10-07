AudioPlayer = require './audioPlayer'
AudioQueue = require './audioQueue'

# Additional data about servers
class BotGuildManager
  constructor: (@engine)->
    @guilds = {}

  addGuild: (guild)=>
    @guilds[guild.id] =
      enabled: true,
      converting: false,
      admins: [],
    g = @guilds[guild.id]
    # Server Specific Class Instances
    g.audioPlayer = new AudioPlayer @engine, guild
    g.queue = new AudioQueue @engine, guild
    g

module.exports = BotGuildManager
