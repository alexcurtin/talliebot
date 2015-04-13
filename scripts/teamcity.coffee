# Description:
#   wrapper for TeamCity REST API for deployments
#
# Dependencies:
#   "underscore": "1.3.3"
#
# Configuration:
#   HUBOT_TEAMCITY_USERNAME = <user name>
#   HUBOT_TEAMCITY_PASSWORD = <password>
#   HUBOT_TEAMCITY_HOSTNAME = <host : port>
#   HUBOT_TEAMCITY_SCHEME = <http || https> defaults to http if not set.
#
# Commands:
#   hubot deploy <project> - Deploy project named <project>
#   hubot deploy branch <project> - Deploy branch project named <project>
#
# Author:
#   Kevin Van Heusen

util = require 'util'
_    = require 'underscore'

module.exports = (robot) ->

  # Deploy
  robot.respond /deploy (.*)/i, (msg) ->
    username = process.env.HUBOT_TEAMCITY_USERNAME
    password = process.env.HUBOT_TEAMCITY_PASSWORD
    hostname = process.env.HUBOT_TEAMCITY_HOSTNAME
    scheme = process.env.HUBOT_TEAMCITY_SCHEME || "http"
    base_url = "#{scheme}://#{hostname}"

    query = msg.match[1]

    map =
      'cloud': 'bt8811'
      'db': 'bt89111'

    if query == "all"
      console.log "deploy all"
      for projectName, buildId of map
        console.log "deploy", projectName, buildId
        url = "#{base_url}/httpAuth/action.html?add2Queue=#{buildId}"
        headers = Authorization: "Basic #{new Buffer("#{username}:#{password}").toString("base64")}", Accept: "application/json"
        msg.http(url)
          .headers(headers)
          .get() (err, res, body, projectName = projectName, buildId = buildId) ->
            if res.statusCode == 200
              msg.send("Deploying #{projectName}")
            else
              msg.send("Fail! Something went wrong. Couldn't start the build for some reason. Build Id is #{buildId}")
    else
      buildId = map[query]
      projectName = query
      if projectName? or buildId?
        console.log "deploy", projectName, buildId
        url = "#{base_url}/httpAuth/action.html?add2Queue=#{buildId}"
        headers = Authorization: "Basic #{new Buffer("#{username}:#{password}").toString("base64")}", Accept: "application/json"
        msg.http(url)
          .headers(headers)
          .get() (err, res, body, projectName = projectName, buildId = buildId) ->
            if res.statusCode == 200
              msg.send("Deploying #{projectName}")
            else
              msg.send("Fail! Something went wrong. Couldn't start the build for some reason. Build Id is #{buildId}")
    return true

  robot.respond /deploy branch (.*)/i, (msg) ->
    username = process.env.HUBOT_TEAMCITY_USERNAME
    password = process.env.HUBOT_TEAMCITY_PASSWORD
    hostname = process.env.HUBOT_TEAMCITY_HOSTNAME
    scheme = process.env.HUBOT_TEAMCITY_SCHEME || "http"
    base_url = "#{scheme}://#{hostname}"
    query = msg.match[1]

    map =
      'cloud': 'branch1'
      'db': 'branch2'

    if query == "all"
      console.log "deploy all"
      for projectName, buildId of map
        console.log "deploy", projectName, buildId
        url = "#{base_url}/httpAuth/action.html?add2Queue=#{buildId}"
        headers = Authorization: "Basic #{new Buffer("#{username}:#{password}").toString("base64")}", Accept: "application/json"
        msg.http(url)
          .headers(headers)
          .get() (err, res, body, projectName = projectName, buildId = buildId) ->
            if res.statusCode == 200
              msg.send("Deploying #{projectName}")
            else
              msg.send("Fail! Something went wrong. Couldn't start the build for some reason. Build Id is #{buildId}")
    else
      buildId = map[query]
      projectName = query
      if projectName? or buildId?
        console.log "deploy", projectName, buildId
        url = "#{base_url}/httpAuth/action.html?add2Queue=#{buildId}"
        headers = Authorization: "Basic #{new Buffer("#{username}:#{password}").toString("base64")}", Accept: "application/json"
        msg.http(url)
          .headers(headers)
          .get() (err, res, body, projectName = projectName, buildId = buildId) ->
            if res.statusCode == 200
              msg.send("Deploying #{projectName}")
            else
              msg.send("Fail! Something went wrong. Couldn't start the build for some reason. Build Id is #{buildId}")
    return true
