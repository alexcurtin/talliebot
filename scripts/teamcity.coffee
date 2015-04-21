# Description:
#     wrapper for TeamCity REST API for deployments
#
# Dependencies:
#     "underscore": "1.3.3"
#
# Configuration:
#     HUBOT_TEAMCITY_USERNAME = <user name>
#     HUBOT_TEAMCITY_PASSWORD = <password>
#     HUBOT_TEAMCITY_HOSTNAME = <host : port>
#     HUBOT_TEAMCITY_SCHEME = <http || https> defaults to http if not set.
#
# Commands:
#     hubot deploy <project> - Deploy project named <project>
#     hubot deploy branch <project> - Deploy branch project named <project>
#
# Author:
#     Kevin Van Heusen

util = require 'util'
_        = require 'underscore'

module.exports = (robot) ->

    # TRUNK PROJECT MAPPING
    trunkMap =
        'cloud': 'bt88'
        'db': 'bt89'
        'marketing': 'bt102'
        'web': 'bt87'
        'viselde': 'Deploy_DeployViseldeAlpha'
        'test': '0'

    # BRANCH PROJECT MAPPING
    branchMap =
        'cloud': 'DeployBranch_DeployTallieCloud'
        'db': 'DeployBranch_DeployTallieDb'
        'marketing': 'DeployBranch_DeployMarketing'
        'web': 'DeployBranch_DeployTallieWeb'
        'viselde': 'DeployBranch_DeployViseldeAlpha'
        'test': '0'

    # DEPLOY
    robot.respond /deploy (.*)/i, (msg) ->
        username = process.env.HUBOT_TEAMCITY_USERNAME
        password = process.env.HUBOT_TEAMCITY_PASSWORD
        hostname = process.env.HUBOT_TEAMCITY_HOSTNAME
        scheme = process.env.HUBOT_TEAMCITY_SCHEME || "http"
        base_url = "#{scheme}://#{hostname}"

        query = msg.match[1]

        if query == "all"
            console.log "deploy trunk all (disabled)"
            ###
            for projectName, buildId of trunkMap
                console.log "deploy", projectName, buildId
                url = "#{base_url}/httpAuth/action.html?add2Queue=#{buildId}"
                headers = Authorization: "Basic #{new Buffer("#{username}:#{password}").toString("base64")}", Accept: "application/json"
                msg.http(url)
                    .headers(headers)
                    .get() (err, res, body) ->
                     if res.statusCode == 200
                            msg.send("/me is deploying #{projectName} from trunk.")
                        elset
                            msg.send("/me failed! Something went wrong. Couldn't start the build for some reason. Build Id is #{buildId}")
            ###
        else
            buildId = trunkMap[query]
            projectName = query
            if projectName? and buildId?
                console.log "deploy trunk", projectName, buildId
                url = "#{base_url}/httpAuth/action.html?add2Queue=#{buildId}"
                headers = Authorization: "Basic #{new Buffer("#{username}:#{password}").toString("base64")}", Accept: "application/json"
                msg.http(url)
                    .headers(headers)
                    .get() (err, res, body) ->
                        if res.statusCode == 200
                            msg.send("/me is deploying #{projectName} from trunk.")
                        else
                            msg.send("/me failed! Something went wrong. Couldn't start the build for some reason. Build Id is #{buildId}")
            else
                msg.send("/me cannot find project '#{projectName}'")
        return true


    # DEPLOY BRANCH
    robot.respond /deploy branch (.*)/i, (msg) ->
        username = process.env.HUBOT_TEAMCITY_USERNAME
        password = process.env.HUBOT_TEAMCITY_PASSWORD
        hostname = process.env.HUBOT_TEAMCITY_HOSTNAME
        scheme = process.env.HUBOT_TEAMCITY_SCHEME || "http"
        base_url = "#{scheme}://#{hostname}"
        query = msg.match[1]

        if query == "all"
            console.log "deploy branch all (disabled)"
            ###
            for projectName, buildId of branchMap
                console.log "deploy", projectName, buildId
                url = "#{base_url}/httpAuth/action.html?add2Queue=#{buildId}"
                headers = Authorization: "Basic #{new Buffer("#{username}:#{password}").toString("base64")}", Accept: "application/json"
                msg.http(url)
                    .headers(headers)
                    .get() (err, res, body) ->
                        if res.statusCode == 200
                            msg.send("/me is deploying #{projectName} from branch.")
                        else
                            msg.send("/me failed! Something went wrong. Couldn't start the build for some reason. Build Id is #{buildId}")
            ###
        else
            buildId = branchMap[query]
            projectName = query
            if projectName? and buildId?
                console.log "deploy branch", projectName, buildId
                url = "#{base_url}/httpAuth/action.html?add2Queue=#{buildId}"
                headers = Authorization: "Basic #{new Buffer("#{username}:#{password}").toString("base64")}", Accept: "application/json"
                msg.http(url)
                    .headers(headers)
                    .get() (err, res, body) ->
                        if res.statusCode == 200
                            msg.send("/me is deploying #{projectName} from branch.")
                        else
                            msg.send("/me failed! Something went wrong. Couldn't start the build for some reason. Build Id is #{buildId}")
            else
                msg.send("/me cannot find project '#{projectName}'")
        return true

    # DEPLOY HELP
    robot.respond /deploy help, (msg) ->
        help = ""
        for projectName, buildId of trunkMap
            help = "deploy " + projectName + "\n"
        for projectName, buildId of branchMap
            help = "deploy branch " + projectName + "\n"

        msg.send("/quote " + help)
        return true
