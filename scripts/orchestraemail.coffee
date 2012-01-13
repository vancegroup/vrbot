# Uses gmail as a low-fi API to Orchestra task creation.
#
# You need to set the following variables:
#   HUBOT_ORCHESTRA_GMAIL_ADDRESS ="<gmail address>"
#   HUBOT_ORCHESTRA_GMAIL_PASSWORD ="<gmail password>"
#   HUBOT_ORCHESTRA_DEFAULT ="#<default list>"
#   HUBOT_ORCHESTRA_LISTS = "<json array of all known lists>"
#
# Make sure to use the full address, and create an account on Orchestra
# with that address and with access to all the lists you want.
#
# You can specify the list name with #listname at the end of your message.
#
# tasklists -- replies with the tasklists you may specify as at the end of "create task"
# create task <task info here> [#<optional list name>]-- Creates a task in Orchestra.

email = require('emailjs')

module.exports = (robot) ->
  known_lists = JSON.parse(process.env.HUBOT_ORCHESTRA_LISTS)

  robot.respond /tasklists/i, (msg) ->
    msg.reply "By default, tasks go to #{process.env.HUBOT_ORCHESTRA_DEFAULT}, or you can specify one of these at the end of your message: #{known_lists.join(', ')}"

  robot.respond /create task ([^#]*)(#.*)?/i, (msg) ->
    task = msg.match[1]
    listname = msg.match[2] || process.env.HUBOT_ORCHESTRA_DEFAULT
    if not listname in known_lists
      msg.reply "I don't know list #{listname}, only these: #{known_lists.join(', ')}"
      return

    #msg.reply "Creating orchestra task '#{task}' on list '#{listname}'"

    contents =
      text:    "Task created in Talker by #{msg.message.user.name}. @anyone #{listname}",
      from:    "VRBot <vance.group.bots@gmail.com>",
      to:      "<tasks-silent@orchestra.com>",
      subject: task


    serv = email.server.connect
      user: process.env.HUBOT_ORCHESTRA_GMAIL_ADDRESS,
      password: process.env.HUBOT_ORCHESTRA_GMAIL_PASSWORD,
      host:    "smtp.gmail.com",
      ssl:     true
    serv.send contents, (err, message) ->
      if err then msg.reply "Something went wrong creating orchestra task '#{task}' on list '#{listname}': #{err}" else msg.reply "Created orchestra task '#{task}' on list '#{listname}'"

