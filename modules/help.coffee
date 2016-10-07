class HelpModule extends BotModule
  init: =>
    {@prefix} = @engine
    @registerCommand 'help', @helpCommandFunction

  helpCommandFunction: (msg, args)=>
    reply = """
    **MIDIBot Beta #{@engine.version} (#{@engine.versionName})**
    Made by <@164588804362076160>

    This bot works much like most music bots, except it converts to midi! :D
    
    To add this garbage to your server, use this:
    https://discordapp.com/oauth2/authorize?client_id=206474212561387520&scope=bot&permissions=8192
    
    This bot is in an experimental phase, if you find any bugs feel free to send me a DM

    Command List:
    
    ```
    Available to Everyone:
    #{@prefix}convert <link/title> - Converts to midi and gives a download link.
    #{@prefix}play    <link/title> - Converts to midi and plays the result in current voice channel.
    #{@prefix}queue                - Shows the current play queue
    #{@prefix}undo                 - Removes the most recent item added to the queue
    #{@prefix}np                   - Now Playing
    #{@prefix}help                 - Shows this help
    #{@prefix}stats                - Technical stuff about the bot
    #{@prefix}ping                 - Pong!

    Bot Commanders:
    #{@prefix}volume  <vol>        - Sets volume of the bot
    #{@prefix}skip                 - Skips currently playing MIDI
    #{@prefix}shuffle              - Shuffles the queue
    #{@prefix}remove <position>    - Removes the song at the specified position
    #{@prefix}swap <pos1> <pos2>   - Swaps the positions of the specified items
    #{@prefix}stop                 - Stops MIDI playback and clears the queue
    #{@prefix}setnick              - Sets the nickname of the bot
    #{@prefix}clean                - Deletes messages sent by the bot (requires permission to do so)
    ```
    """
    msg.author.openDM().then (dm)=>
      dm.sendMessage reply
      msg.reply 'Check your DMs!' if msg.channel.guild_id

module.exports = HelpModule
