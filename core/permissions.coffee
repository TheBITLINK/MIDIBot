class BotPermissionManager
  constructor: (@engine)->
    {@bot, @serverData} = @engine
    {@owner, @admins, @adminRoles} = @engine.settings
    @serverAdmins
  
  updateAdmins: =>
    for server in @bot.servers
      @serverData.servers[server.id].admins = []
      for role in server.roles
        if role.name in @adminRoles
          try
            for user in server.usersWithRole(role)
              @serverData.servers[server.id].admins.push(user.id)

  updateAdminsInServer: (server)=>
    @serverData.servers[server.id].admins = []
    for role in server.roles
      if role.name in @adminRoles
        try
          for user in server.usersWithRole(role)
            @serverData.servers[server.id].admins.push(user.id)

  isAdmin: (user, server, globalOnly)=>
    return true if user.id in @admins or user.id in @owner or user.id is server.owner.id
    if not globalOnly
      for n in @adminRoles
        for role in server.roles.getAll('name', n)
          return true if user in server.usersWithRole(role)
    false
    
  isOwner: (user)=> user.id in @owner

module.exports = BotPermissionManager