# Additional data about servers
class BotServerManager
  constructor: (@engine)->
    @servers = {}

  initServers: (servers)=>
    @addServer server for server in servers
  
  addServer: (server)=>
    @servers[server.id] =
      enabled: true,
      admins: []
    
  removeServer: (server)=>
    @servers[server.id] = null

module.exports = BotServerManager
