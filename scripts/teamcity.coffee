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
#     hubot deploy cloud - Deploy cloud services from trunk
#     hubot deploy db - Deploy database from trunk
#     hubot deploy marketing - Deploy marketing from trunk
#     hubot deploy web - Deploy web from trunk
#     hubot deploy viselde - Deploy viselde services from trunk
#     hubot deploy branch all - Deploy all projects from branch
#     hubot deploy branch cloud - Deploy cloud services from branch
#     hubot deploy branch db - Deploy database from branch
#     hubot deploy branch marketing - Deploy marketing from branch
#     hubot deploy branch web - Deploy web from branch
#     hubot deploy branch viselde - Deploy viselde services from branch
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

    # RESPOND TO DEPLOY
    robot.respond /deploy (.*)/i, (msg) ->
        query = msg.match[1]

        isBranch = query.match(/branch (.*)/i)?
        if isBranch
            query = isBranch[1]
            map = branchMap
            env = "branch"
        else
            map = trunkMap
            env = "trunk"
        msg.send("Console: isBranch?", isBranch, "query", query, "env", env)

        if query == "all"
            for projectName, buildId of testMap # FIXME: set it to map
                add2Queue(msg, projectName, buildId, env)
        else
            if (projectName = query)? and (buildId = map[query])?
                add2Queue(msg, projectName, buildId, env)
            else
                msg.send("/me cannot find project '#{projectName}'")
        return true
