###
The Main Server Class
###
Discord = require 'discord.js'
CommandManager = require './commands'
ModuleManager = require './modules'
PermissionManager = require './permissions'
ServerManager = require './servers'

class BotEngine
  constructor: (@settings) ->
    {@prefix} = @settings
    @bot = new Discord.Client
    @serverData = new ServerManager this
    @permissions = new PermissionManager this
    @commands = new CommandManager this
    @modules = new ModuleManager this
    @bot.on 'ready', @onReady
    @bot.on 'serverCreated', @onServerCreated
    @bot.on 'serverDeleted', @onServerDeleted
    @bot.on 'serverRoleCreated', @onServerRoleCreated
    @bot.on 'serverRoleDeleted', @onServerRoleDeleted
    @bot.on 'serverRoleUpdated', @onServerRoleUpdated
    @bot.on 'message', @onMessage
    @bot.on 'disconnected', @establishConnection
    
  onReady: =>
    @bot.setPlayingGame @prefix+'help'
    @serverData.initServers @bot.servers
    @permissions.updateAdmins()
  
  onServerCreated: (server)=>
    @serverData.addServer server
    @permissions.updateAdmins()

  onServerDeleted: (server)=> @serverData.removeServer server

  onServerRoleCreated: (role)=> @permissions.updateAdmins()
  onServerRoleDeleted: (role)=> @permissions.updateAdmins()
  onServerRoleUpdated: (oldRole, newRole)=> @permissions.updateAdmins()

  onMessage: (msg)=>
    try
      if msg.server
        return if not @serverData.servers[msg.server.id].enabled and not @permissions.isAdmin(msg.author, msg.server)
    if msg.content[..@prefix.length-1] is @prefix
      @commands.executeCommand msg

  establishConnection: =>
    @bot.loginWithToken @settings.token

module.exports = BotEngine