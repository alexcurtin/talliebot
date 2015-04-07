# Description:
#	 wrapper for TeamCity REST API for deployments
#
# Dependencies:
#	 "underscore": "1.3.3"
#
# Configuration:
#	 HUBOT_TEAMCITY_USERNAME = <user name>
#	 HUBOT_TEAMCITY_PASSWORD = <password>
#	 HUBOT_TEAMCITY_HOSTNAME = <host : port>
#	 HUBOT_TEAMCITY_SCHEME = <http || https> defaults to http if not set.
#
# Commands:
#	 hubot deploy <project> - Deploy project named <project>
#	 hubot deploy branch <project> - Deploy branch project named <project>
#
# Author:
#	 Kevin Van Heusen

util = require 'util'
_    = require 'underscore'

console.log "1"
module.exports = (robot) ->
username = process.env.HUBOT_TEAMCITY_USERNAME
password = process.env.HUBOT_TEAMCITY_PASSWORD
hostname = process.env.HUBOT_TEAMCITY_HOSTNAME
scheme = process.env.HUBOT_TEAMCITY_SCHEME || "http"
base_url = "#{scheme}://#{hostname}"
console.log "2"
# trunk TC deploy projects - map of friendly alias to TC build ID
trunkProjectMap =
   'cloud': 'bt88'
   'db': 'bt89'
   'database': 'bt89'
console.log "3"
# branch TC deploy projects - map of friendly alias to TC build ID
branchProjectMap =
        'cloud': 'branch1'
        'db': 'branch2'
        'database': 'branch2'
console.log "4"
# Deploy the correct builds
deploy: (msg = {}, map = {}) ->
console.log "5"
projectName = msg.match[1]
     if projectName == "all"
         for key, value of map
             @add2Queue(msg, projectName, value)
         else
            for key, value of map
            @add2Queue(msg, projectName, value) if key == projectName
        return true

# Add to deploy queue
add2Queue: (msg, projectName, buildId) ->
console.log "6"
url = "#{base_url}/httpAuth/action.html?add2Queue=#{buildId}"
headers = Authorization: "Basic #{new Buffer("#{username}:#{password}").toString("base64")}", Accept: "application/json"
msg.http(url)
.headers(headers)
.get() (err, res, body) ->
if res.statusCode == 200
msg.send("Deploying #{projectName}")
else
msg.send("Fail! Something went wrong. Couldn't start the build for some reason. Build Id is #{buildId}")
return true

# Deploy
console.log "7"
robot.respond /deploy (.*)/i, (msg) -> @deploy(msg, @trunkProjectMap)
console.log "8"
robot.respond /deploy branch (.*)/i, (msg) -> @deploy(msg, @branchProjectMap)
console.log "9"
