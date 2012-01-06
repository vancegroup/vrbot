# compiling is not slacking off

module.exports = (robot) ->
  robot.hear /compiling/i, (msg) ->
    msg.reply 'is not slacking off.'
