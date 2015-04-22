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
#     hubot deploy all - Deploy all projects from trunk
#     hubot deploy <project> - Deploy project named <project> from trunk
#     hubot deploy branch all - Deploy all projects from branch
#     hubot deploy branch <project> - Deploy project named <project> from branch
#     hubot deploy help - List all available projects
#
# Author:
#     Kevin Van Heusen

util = require 'util'
_ = require 'underscore'

module.exports = (robot) ->

    # TRUNK PROJECT MAPPING
    trunkMap =
        'cloud': 'bt88'
        'db': 'bt89'
        'marketing': 'bt102'
        'web': 'bt87'
        'viselde': 'Deploy_DeployViseldeAlpha'
        'test': '0' # FIXME: remove this

    # BRANCH PROJECT MAPPING
    branchMap =
        'cloud': 'DeployBranch_DeployTallieCloud'
        'db': 'DeployBranch_DeployTallieDb'
        'marketing': 'DeployBranch_DeployMarketing'
        'web': 'DeployBranch_DeployTallieWeb'
        'viselde': 'DeployBranch_DeployViseldeAlpha'
        'test': '0' # FIXME: remove this

    # FIXME: remove this
    testMap =
        'aa': '11'
        'bb': '22'
        'cc': '33'

    # ADD PROJECT 2 QUEUE
    add2Queue = (msg, projectName, buildId, env) =>
        console.log "add2Queue", projectName, buildId, env

        username = process.env.HUBOT_TEAMCITY_USERNAME
        password = process.env.HUBOT_TEAMCITY_PASSWORD
        hostname = process.env.HUBOT_TEAMCITY_HOSTNAME
        scheme = process.env.HUBOT_TEAMCITY_SCHEME || "http"
        base_url = "#{scheme}://#{hostname}"
        url = "#{base_url}/httpAuth/action.html?add2Queue=#{buildId}"
        headers =
            Authorization: "Basic #{new Buffer("#{username}:#{password}").toString("base64")}"
            Accept: "application/json"

        msg.http(url)
            .headers(headers)
            .get() (err, res, body) ->
                if res.statusCode == 200
                    msg.send("/me is deploying #{projectName} from #{env}.")
                else
                    msg.send("/me cannot start the build for some reason. Build Id is #{buildId}.")
        return true

    # RESPOND TO DEPLOY TRUNK
    robot.respond /deploy (.*)/i, (msg) ->
        query = msg.match[1]

        isDeployBranch = query.indexOf "branch" > -1
        isDeployHelp = query.indexOf "help" > -1
        if !(isDeployBranch or isDeployHelp)
            if query == "all"
                for projectName, buildId of testMap # FIXME: set it to actual map
                    add2Queue(msg, projectName, buildId, env = "trunk")
            else
                if (projectName = query)? and (buildId = trunkMap[query])?
                    add2Queue(msg, projectName, buildId, env = "trunk")
                else
                    msg.send("/me cannot find project '#{projectName}'")
        return true


    # RESPOND TO DEPLOY BRANCH
    robot.respond /deploy branch (.*)/i, (msg) ->
        query = msg.match[1]

        if query == "all"
            for projectName, buildId of testMap # FIXME: set it to actual map
                add2Queue msg, projectName, buildId, env = "branch"
        else
            if (projectName = query)? and (buildId = branchMap[query])?
                add2Queue msg, projectName, buildId, env = "branch"
            else
                msg.send "/me cannot find project '#{projectName}'"

        return true

    # RESPOND TO DEPLOY HELP
    robot.respond /deploy help/i, (msg) ->
        help = ""
        help += "deploy all \n"
        for projectName, buildId of trunkMap
            help += "deploy " + projectName + "\n"
        help += "deploy branch all \n"
        for projectName, buildId of branchMap
            help += "deploy branch " + projectName + "\n"
        msg.send("/quote " + help)
        return true
