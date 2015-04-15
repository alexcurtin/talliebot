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
    ,
      "Oh. That was my bad. I'm sorry."
    ,
      "I did it but I'm blaming you."
    ,
      "Sure, I'll take the blame."
    ,
      "I'm not a hard worker but I'm willing to take the blame for whatever you want."
    ,
      "Not sure if I should take the credit.. or take the blame?!"
    ,
      "I've done enough wrong on my own, I don't want to get blamed for something I didn't do."
    ,
      "I'm sorry. It's my fault. What can I do to make it right?"
    ,
      "It's always my fault, isn't it?"
    ,
      "What did I do wrong again?"
    ,
      "Okay, I will bring (donuts)"
    ,
      "(sadpanda)"
    ,
      "(areyoukiddingme)"
    ,
      "(tableflip)"
    ]
    blame = blames[Math.floor( Math.random() * blames.length)]
    msg.send blame
