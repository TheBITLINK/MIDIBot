childProcess = require 'child_process'

class AdminModule
  constructor: (@engine)->
    {@bot, @commands, @serverData} = @engine
    # Admin Commands
    adminOptions =
      adminOnly: true
    @setnickCommand =  @commands.registerCommand 'setnick', adminOptions, @setnickFunc
    @enableCommand =  @commands.registerCommand 'enable', adminOptions, @enableFunc
    @disableCommand =  @commands.registerCommand 'disable', adminOptions, @disableFunc
    # Restart Command
    restartOptions =
      ownerOnly: true
    @restartCommand = @commands.registerCommand 'restart', restartOptions, @restartFunc
    @updateCommand = @commands.registerCommand 'update', restartOptions, @updateFunc

  setnickFunc: (msg, args)=>
    @bot.setNickname msg.server, args, @bot.user, (error)=>
      if error?
        @bot.sendMessage msg.channel "Couldn't set nickname for the bot. Make sure it has enough permissions."
      else
        @bot.sendMessage msg.channel "Nickname changed succesfully!"

  enableFunc: (msg)=>
    @serverData.servers[msg.server.id].enabled = true
    @bot.sendMessage msg.channel, 'MIDIBot enabled for this server.'

  disableFunc: (msg)=>
    @serverData.servers[msg.server.id].enabled = false
    @bot.sendMessage msg.channel, 'MIDIBot disabled for this server (will only accept commands from server admins).'

  restartFunc: (msg)=>
    @bot.sendMessage msg.channel, 'MIDIBot is restarting...'
    setTimeout process.exit, 2000 # Let's hope PM2 restarts it :)

  updateFunc: (msg,args,bot)=>
    childProcess.exec 'git pull origin master', (error, stdout, stderr)->
      bot.sendMessage msg.channel, """
                       ```diff
                       + $ git pull origin master

                       """+stdout+"""
                       ```
                       MIDIBot is restarting...
                       """
      setTimeout process.exit, 2000

  shutdown: =>
    @commands.unregisterCommands [@setnickCommand, @enableCommand, @disableCommand, @restartCommand, @updateCommand]

module.exports = AdminModule