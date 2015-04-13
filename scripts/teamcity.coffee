# Description:
#    wrapper for TeamCity REST API for deployments
#
# Dependencies:
#    "underscore": "1.3.3"
#
# Configuration:
#    HUBOT_TEAMCITY_USERNAME = <user name>
#    HUBOT_TEAMCITY_PASSWORD = <password>
#    HUBOT_TEAMCITY_HOSTNAME = <host : port>
#    HUBOT_TEAMCITY_SCHEME = <http || https> defaults to http if not set.
#
# Commands:
#    hubot deploy <project> - Deploy project named <project>
#    hubot deploy branch <project> - Deploy branch project named <project>
#
# Author:
#    Alex Curtin

module.exports = (robot) ->
  robot.respond /deploy (.*)/i, (msg) ->
    username = process.env.HUBOT_TEAMCITY_USERNAME
    password = process.env.HUBOT_TEAMCITY_PASSWORD
    hostname = process.env.HUBOT_TEAMCITY_HOSTNAME
    buildId = msg.match[1]
    
    buildMappings = 
     ' web': 'bt38', 
      'database': 'bt38' # put real project ids here
    

    projectId = buildMappings[buildId]

    msg.http("http://#{hostname}/httpAuth/action.html?add2Queue=#{projectId}")
     .headers(Authorization: "Basic #{new Buffer("#{username}:#{password}").toString("base64")}", Accept: "application/json")
     .get() (err, res, body) ->
        if res.statusCode == 200
          msg.send("Deploying #{buildId}")
        else
          msg.send("Fail! Something went wrong. Couldn't start the build for some reason. Build Id is #{buildId}")
          return
