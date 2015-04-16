# Description:
#   Use talliebot to keep track of donuts
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   talliebot <someone> owes donuts - increases someone's donut counter
#   talliebot <someone> brought donuts - reduces someone's donut counter
#   talliebot does <someone> owe donuts - returns someone's donut counter
#
# Author:
#   Will Schuur

module.exports = (robot) ->
  donutStringSuffix = 'donuts'
  donutEmote = '(donuts)'

  robot.respond /(.*) owes donuts/i, (msg) ->
    name = msg.match[1].trim
    users = robot.brain.usersForFuzzyName name
    if users.length is 1
      user = users[0]
      userDonutsString = user + donutStringSuffix
      userDonuts = robot.brain.get(userDonutsstring) * 1 or 0
      robot.brain.set userDonutsString, userDonuts+1
      response = "mmm... " + user + " owes "
      for donut in userDonuts
        response = response + donutEmote + " "
      msg.send response

  robot.respond /(.*) brought donuts/i, (msg) ->
    name = msg.match[1].trim
    users = robot.brain.usersForFuzzyName name
    if users.length is 1
      user = users[0]
      userDonutsString = user + donutStringSuffix
      userDonuts = robot.brain.get(userDonutsString) * 1 or 0
      if userDonuts > 0
        userDonuts = userDonuts-1
        robot.brain.set userDonutsString, userDonuts
        response = "Wahoo! Thanks " + user + " for the " + donutEmote + ". You still owe "
        for donut in userDonuts
          response = response + donutEmote + " "
      else
        response = user + " didn't even owe donuts!"
      msg.send response

  robot.respond /Does (.*) owe donuts/i, (msg) ->
    name = msg.match[1].trim
    users = robot.brain.usersForFuzzyName name
    if users.length is 1
      user = users[0]
      userDonutsString = user + donutStringSuffix
      userDonuts = robot.brain.get(userDonutsString) * 1 or 0
      if userDonuts > 0
        response = user + " owes"
        for donut in userDonuts
          response = response + donutEmote + " "
      else
        response = user + " doesnt't owe donuts" 
      msg.send response
