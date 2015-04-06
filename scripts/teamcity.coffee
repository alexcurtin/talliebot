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

util					 = require 'util'
_							= require 'underscore'

module.exports = (robot) ->
	username = process.env.HUBOT_TEAMCITY_USERNAME
	password = process.env.HUBOT_TEAMCITY_PASSWORD
	hostname = process.env.HUBOT_TEAMCITY_HOSTNAME
	scheme = process.env.HUBOT_TEAMCITY_SCHEME || "http"
	base_url = "#{scheme}://#{hostname}"

	# trunk TC deploy projects - map of friendly alias to TC build ID
	trunkProjectMap = [
		'cloud': 'bt88'
	,
		'db': 'bt89'
	,
		'database': 'bt89'
	]

	# branch TC deploy projects - map of friendly alias to TC build ID
	branchProjectMap = [
		'cloud': 'branch1'
	,
		'db': 'branch2'
	,
		'database': 'branch2'
	]

	getAuthHeader = ->
		return Authorization: "Basic #{new Buffer("#{username}:#{password}").toString("base64")}", Accept: "application/json"

	# Deploy trunk
	robot.respond /deploy (.*)/i, (msg) ->
		projectName = msg.match[1]
		buildId = trunkProjectMap[projectName]

		url = "#{base_url}/httpAuth/action.html?add2Queue=#{buildId}"
		msg.http(url)
				.headers(getAuthHeader())
				.get() (err, res, body) ->
					err = body unless res.statusCode == 200
					if err
						msg.send "Fail! Something went wrong. Couldn't start the build for some reason. Build Id is #{buildId}"
					else
						msg.send "Deploying #{projectName}"

	# Deploy all trunk
	robot.respond /deploy all (.*)/i, (msg) ->
		projectName = msg.match[1]
		buildId = trunkProjectMap[projectName]
		for project of trunkProjectMap

		url = "#{base_url}/httpAuth/action.html?add2Queue=#{buildId}"
		msg.http(url)
				.headers(getAuthHeader())
				.get() (err, res, body) ->
					err = body unless res.statusCode == 200
					if err
						msg.send "Fail! Something went wrong. Couldn't start the build for some reason. Build Id is #{buildId}"
					else
						msg.send "Deploying #{projectName}"


	# Deploy branch
	robot.respond /deploy branch (.*)/i, (msg) ->
		projectName = msg.match[1]
		buildId = branchProjectMap[projectName]

		url = "#{base_url}/httpAuth/action.html?add2Queue=#{buildId}"
		msg.http(url)
				.headers(getAuthHeader())
				.get() (err, res, body) ->
					err = body unless res.statusCode == 200
					if err
						msg.send "Fail! Something went wrong. Couldn't start the build for some reason. Build Id is #{buildId}"
					else
						msg.send "Deploying branch #{projectName}"


