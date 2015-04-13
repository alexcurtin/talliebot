module.exports = (robot) ->
robot.respond /deploy (.*)/i, (msg) ->
username = process.env.HUBOT_TEAMCITY_USERNAME
password = process.env.HUBOT_TEAMCITY_PASSWORD
hostname = process.env.HUBOT_TEAMCITY_HOSTNAME
buildId = msg.match[1]

msg.http("http://#{hostname}/httpAuth/action.html?add2Queue=#{buildId}")
.headers(Authorization: "Basic #{new Buffer("#{username}:#{password}").toString("base64")}", Accept: "application/json")
.get() (err, res, body) ->
if res.statusCode == 200
msg.send("Deploying #{buildId}")
else
msg.send("Fail! Something went wrong. Couldn't start the build for some reason. Build Id is #{buildId}")
return
