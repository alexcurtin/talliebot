# Description:
#   Blame hubot for anything
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot take the blame - For everything
#   hubot take the blame for <something> - For <something>
#
# Author:
#   Ben Armston

module.exports = (robot) ->
  robot.respond /take the blame/i, (msg) ->
    blames = [
      "/me shamefully sits there and silently takes the blame."
    ,
      "Oscar Wilde told me to do it!"
    ]
    blame = blames[Math.floor( Math.random() * blames.length)]
    msg.send blame
