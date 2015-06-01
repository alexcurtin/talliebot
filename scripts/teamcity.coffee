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
#     hubot deploy [trunk|branch] all [alpha|staging] - Deploy all projects
#     hubot deploy [trunk|branch] [cloud|db|marketing|web|viselde] [alpha|staging] - Deploy a specific project
#
# Author:
#     Kevin Van Heusen

util = require 'util'
_ = require 'underscore'

module.exports = (robot) ->

    # TRUNK TO ALPHA PROJECT MAPPING
    trunkToAlphaMap =
        'cloud': 'bt88'
        'db': 'bt89'
        'marketing': 'bt102'
        'web': 'bt87'
        'viselde': 'Deploy_DeployViseldeAlpha'
        #'test': 'test trunk2alpha' #FIXME

    # BRANCH TO ALPHA PROJECT MAPPING
    branchToAlphaMap =
        'cloud': 'DeployBranchAlpha_DeployTallieCloud'
        'db': 'DeployBranchAlpha_DeployTallieDb'
        'marketing': 'DeployBranchAlpha_DeployMarketing'
        'web': 'DeployBranchAlpha_DeployTallieWeb'
        'viselde': 'DeployBranchAlpha_DeployViseldeAlpha'
        #'test': 'test branch2alpha' #FIXME

    # BRANCH TO STAGING PROJECT MAPPING
    branchToStagingMap =
        'cloud': 'DeployBranch_DeployTallieCloud'
        'db': 'DeployBranch_DeployTallieDb'
        'marketing': 'DeployBranch_DeployMarketing'
        'web': 'DeployBranch_DeployTallieWeb'
        'viselde': 'DeployBranch_DeployViseldeAlpha'
        #'test': 'test branch2staging' #FIXME


    # ENUMS

    SOURCE =
        Trunk: "trunk"
        Branch: "branch"

    ENV =
        Alpha: "alpha"
        Staging: "staging"


    # ADD PROJECT 2 QUEUE
    add2Queue = (msg, projectName, buildId, source, env) =>
        console.log "add2Queue", projectName, buildId, env

        username = process.env.HUBOT_TEAMCITY_USERNAME
        password = process.env.HUBOT_TEAMCITY_PASSWORD
        hostname = process.env.HUBOT_TEAMCITY_HOSTNAME
        scheme = process.env.HUBOT_TEAMCITY_SCHEME || "http"
        base_url = "#{scheme}://#{hostname}"
        url = "#{base_url}/httpAuth/action.html?add2Queue=#{buildId}&moveToTop=true"
        headers =
            Authorization: "Basic #{new Buffer("#{username}:#{password}").toString("base64")}"
            Accept: "application/json"

        msg.http(url)
            .headers(headers)
            .get() (err, res, body) ->
                if res.statusCode == 200
                    msg.send("/me is deploying #{projectName} from #{source} to #{env}. @all")
                else
                    msg.send("/me cannot start the build for some reason. Build Id is #{buildId}.")
        return true

    # RESPOND TO DEPLOY
    robot.respond /deploy (.*)/i, (msg) ->
        query = msg.match[1].trim()

        # GET SOURCE [branch|trunk]

        if query.match(/branch/i)?
            query = query.replace(/branch/i, '').trim()
            source = SOURCE.Branch

        else if query.match(/trunk/i)?
            query = query.replace(/trunk/i, '').trim()
            source = SOURCE.Trunk

        else
            # set default source to trunk
            source = SOURCE.Trunk


        # GET ENVIRONMENT [alpha|staging]

        if query.match(/alpha/i)?
            query = query.replace(/alpha/i, '').trim()
            env = ENV.Alpha

        else if query.match(/staging/i)?
            query = query.replace(/staging/i, '').trim()
            env = ENV.Staging

        else
            # set default env to Alpha if deploying from trunk, to Staging if deploying from branch
            env = if source == SOURCE.Trunk then ENV.Alpha else ENV.Staging


        # SET MAPPING

        if source == SOURCE.Trunk

            if env == ENV.Alpha
                map = trunkToAlphaMap

            else if env == ENV.Staging
                map = null
                # Send warning
                console.log "Warning: Deploying from trunk to staging is disabled."
                msg.send("/me cannot deploy '#{query}'. Deploy from trunk to staging is disabled.")

        else if source == SOURCE.Branch

            if env == ENV.Alpha
                map = branchToAlphaMap

            else if env == ENV.Staging
                map = branchToStagingMap


        # KICK OFF DEPLOY REQUEST
        if map?
            console.log "deploy", "source:", source, "environment:", env, "project:", query

            if query == "all"
                for projectName, buildId of map
                    add2Queue(msg, projectName, buildId, source, env)

            else
                if (projectName = query)? and (buildId = map[query])?
                    add2Queue(msg, projectName, buildId, source, env)
                else
                    msg.send("/me cannot find project '#{projectName}'")

        return true
