youtubedl = require 'youtube-dl'
{ spawn } = require 'child_process'
moment = require 'moment'

class VideoUtil
  getInfo: (query)=> new Promise (resolve)=>
    youtubedl.getInfo query, ['--default-search', 'ytsearch', '-f', 'bestaudio'], (err, info)=>
      if err
        return youtubedl.getInfo query, [], (error, info)=>
          return msg.reply 'Something went wrong.' if error
          resolve(@getLength(info))
      resolve(@getLength(info))

  # Try to get the duration from FFProbe (for direct links and other streams)
  getLength: (info)=> new Promise (resolve, reject)=>
    return resolve(info) if isFinite info.duration or typeof info.forEach is 'function'
    ffprobe = spawn('ffprobe', [info.url, '-show_format', '-v', 'quiet'])
    ffprobe.stdout.on 'data', (data)=>
      # Parse the output from FFProbe
      prop = { }
      pattern = /(.*)=(.*)/g
      while match = pattern.exec data
        prop[match[1]] = match[2]
      # Get the duration
      info.duration = prop.duration
      # Try to use metadata from the ID3 tags as well
      if prop['TAG:title']
        info.title = ''
        info.title += "#{prop['TAG:artist']} - " if prop['TAG:artist']
        info.title += prop['TAG:title']
      resolve info
  
  # TODO: At this point, this should be in a global function or something
  parseTime:(time)=>
    t = time.split(':').reverse()
    moment.duration {
      seconds: t[0]
      minutes: t[1]
      hours:   t[2]
    }
    .asSeconds()

module.exports = new VideoUtil()
