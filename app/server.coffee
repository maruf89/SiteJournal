"use strict"

#
# * Express Dependencies
# - Redis
# - Coffeescript
# - lodash

config =
  base: process.env.ABSOLUTE_SSL_URL
  oauthPath: 'oauth2callback'

services      = require('../services.json')

fs            = require 'fs'
http          = require 'http'
https         = require 'https'
express       = require 'express'
coffee        = require "coffee-script"
mvd           = require('./server/MVData')(services, config)
db            = require './server/DB'
path          = require "path"
_             = require 'lodash'

###*  Hold all authenticated services in an array  ###
authenticatedServices = []

###*
 * Iterate through each service and check wether it contains
 * the required fields in the database
 ###
_.each services, (_service, name) ->
  name = name.toLowerCase()
  data = {}
  ###*  retrieve an array of the required keys   ###
  required = mvd.service[name].requiredTokens()
  db.hgetAll 'api', name, required, (err, res) ->
    if err then console.log err
    else
      ###*  test that every statement is non falsey  ###
      if (res.every (a) -> !!a)
        authenticatedServices.push(name)
        ###*  combine the keys and values and pass to the service  ###
        mvd.service[name].addTokens(_.object(required, res))

options =
  key: fs.readFileSync "#{__dirname}/../ssl/localhost.key"
  cert: fs.readFileSync "#{__dirname}/../ssl/certificate.crt"

app = express()
redis = require('redis')
RedisStore = require('connect-redis') express


#
# * Set app settings depending on environment mode.
# * Express automatically sets the environment to 'development'
#
if process.env.NODE_ENV is "production" or process.argv[2] is "production"
  console.log "Setting production env variable"
  app.set "env", "production"

  # this 'dev' variable is available to Jade templates
  app.locals.dev = false
else
  app.locals.dev = true


# * Config
#

app.locals.basedir = '/../'
app.configure ->
  @set "port", 80
  @set "sslPort", 443
  @set "views", __dirname + "/"
  @set "view engine", "jade"
  @use express.logger("dev")  if app.get("env") is "development"

  @use express.cookieParser("keyboardcat") # 'some secret key to sign cookies'
  @use express.session
    store: new RedisStore(
        host: 'localhost'
        port: 6379
    ),
    secret: 'nte234jkTeinuhn234ee2'
  @use express.bodyParser()
  @use express.compress()
  @use express.methodOverride()

  # "app.router" positions our routes
  # above the middleware defined below,
  # this means that Express will attempt
  # to match & call routes _before_ continuing
  # on, at which point we assume it's a 404 because
  # no route has handled the request.
  @.use app.router

  @.use require("connect-asset")(
    assets: path.resolve __dirname
    public: path.resolve "#{app.locals.basedir}.tmp"
    buidls: true
  )
  @.use require("stylus").middleware(
    src: "#{@locals.basedir}.tmp/styles"
    compress: true
  )


# our custom "verbose errors" setting
# which we can use in the templates
# via settings['verbose errors']
app.enable "verbose errors"

# disable them in production
# use $ NODE_ENV=production node server.js
app.disable "verbose errors"  if app.get("env") is "production"



# host dev files if in dev mode
if app.get("env") is "development"
  app.use express.static(".tmp")
  app.use express.static("app")
else
  app.use express.static("dist")

require('./routes')(app)

serverHTTP = http.createServer( app ).listen app.locals.settings.port, '173.234.60.108', ->
   console.log "HTTP server started on port #{app.locals.settings.port}"

serverHTTPS = https.createServer( options, app ).listen app.locals.settings.sslPort, '173.234.60.108', ->
  console.log "HTTPS server started on port #{app.locals.settings.sslPort}"

# app.listen app.locals.settings.port
