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
#    Kevin Van Heusen

util                    = require 'util'
_                       = require 'underscore'

console.log "1"
module.exports = (robot) ->
  username = process.env.HUBOT_TEAMCITY_USERNAME
  password = process.env.HUBOT_TEAMCITY_PASSWORD
  hostname = process.env.HUBOT_TEAMCITY_HOSTNAME
  scheme = process.env.HUBOT_TEAMCITY_SCHEME || "http"
  base_url = "#{scheme}://#{hostname}"
  # trunk TC deploy projects - map of friendly alias to TC build ID

  robot.respond /deploy build (.*)/i (msg) ->
    buildId = msg.match[1]
    
    url = "#{base_url}/httpAuth/action.html?add2Queue=#{buildId}"
    headers = Authorization: "Basic #{new Buffer("#{username}:#{password}").toString("base64")}", Accept: "application/json"
    msg.http(url)
    .headers(headers)
    .get() (err, res, body) ->
        if res.statusCode == 200
            msg.send("Deploying #{buildId}")
        else
            msg.send("Fail! Something went wrong. Couldn't start the build for some reason. Build ID is #{buildId}")
            return true

