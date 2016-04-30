express = require("express")
app = express()
fs = require("fs")
Q = require("q")
crypto = require("crypto")

# enable express strict routing, see http://expressjs.com/api.html#app-settings
# for more info
app.enable "strict routing"

###
express app configuration
###
app.configure ->
  app.use express.methodOverride()
  app.use express.bodyParser()

  # strip slashes
  app.use (req, res, next) ->
    if req.url.substr(-1) is "/" and req.url.length > 1
      res.redirect 301, req.url.slice(0, -1)
    else
      next()

  app.use app.router
  app.use express.static("build")

  app.use (req, res) ->
    res.status(404).sendfile "build/404.html"

  app.use express.errorHandler(
    dumpExceptions: false
    showStack: false
  )

###
express app router
###
app.get "/", (req, res, next) ->
  filePath = "build" + req.url + ".html"
  filePath = "build/index.html"  if req.url is "/"
  fs.exists filePath, (exists) ->
    if exists
      res.sendfile filePath
    else
      next()

# final route, if nothing else matched, this will match docs
app.get "*", (req, res, next) ->
  req.url = req.url.toLowerCase()
  filePath = "build/docs/" + req.url + ".html"
  fs.exists filePath, (exists) ->
    if exists
      res.sendfile filePath
    else
      next()


module.exports = (config) ->
  console.log "Starting a server at `#{config.host}` on port: " + config.port
  app.listen config.port
