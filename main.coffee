BotEngine = require './core'
dotenv = require 'dotenv'
mkdirp = require 'mkdirp'

# mkdirp 'data/tmp'
dotenv.config()
botSettings =
  name: 'MIDIBot'
  prefix: process.env.BOT_PREFIX
  token: process.env.BOT_TOKEN
  owner: JSON.parse process.env.BOT_OWNER
  admins: JSON.parse process.env.BOT_ADMINS
  adminRoles: JSON.parse process.env.BOT_ADMIN_ROLES
  djRoles: JSON.parse process.env.BOT_DJ_ROLES

midiBot = new BotEngine botSettings

# Run this shit
midiBot.establishConnection()
# Load Modules
midiBot.modules.load JSON.parse process.env.BOT_MODULES

console.log 'Started.'
