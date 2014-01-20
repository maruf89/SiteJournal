"use strict"

#
# * Express Dependencies
# - Redis
# - Coffeescript
# - lodash

###*  object containing urls and general variables  ###
config =
  base: process.env.ABSOLUTE_SSL_URL
  oauthPath: 'authenticate/oauth2callback'
  app: process.env.APP_URI
  cookieDomain: process.env.COOKIE_DOMAIN

###*  Data Collector config file  ###
dataConfig    = require('../dataConfig.json')

###*  List of services with their OAuth requirements to initiate  ###
services      = require('../../services.json')

###*  Required modules  ###
fs            = require('fs')
http          = require('http')
https         = require('https')
express       = require('express')
coffee        = require('coffee-script')
mvd           = require('./server/MVData').init(services, config)
path          = require('path')


###*  Module that uses mvd and does the actual data requesting  ###
dataCollector = require('./server/DataCollector').configure(dataConfig)

###*  SSL Certificates required to run https  ###
options =
  key: fs.readFileSync "#{__dirname}/../../ssl/localhost.key"
  cert: fs.readFileSync "#{__dirname}/../../ssl/certificate.crt"

###*  Service instantiation + redis session storage  ###
app           = express()
redis         = require('redis')
RedisStore    = require('connect-redis') express

httpServer    = http.createServer(app)
httpsServer   = https.createServer(options, app)

#  bind Socket.io to our http server
socket        = require('socket.io').listen(httpServer)

socketRequest = require('./server/socketRequest')(socket);


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


###*
 * Express Configurations
 ###
app.locals.basedir = './../'
app.configure ->
  @set "port", 9000
  @set "sslPort", 9443
  @set "IPAddress", "mariusmiliunas.com"
  @set "views", __dirname
  @set "view engine", "jade"
  @set "view options", layout: false
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

  ###*  redirects all http://{host} requests to http://www.{host}  ###
  @all(/.*/, (req, res, next) ->
    host = req.header("host")
    if host.match(/^www\..*/i)
      do next
    else
      res.redirect(301, "http://www.#{host}")
  )

  @use require("connect-asset")(
    assets: path.resolve __dirname
    public: path.resolve "#{@locals.basedir}.tmp"
    buidls: true
  )
  @use require("stylus").middleware(
    src: "#{@locals.basedir}.tmp/styles"
    compress: true
  )

  # "app.router" positions our routes
  # above the middleware defined below,
  # this means that Express will attempt
  # to match & call routes _before_ continuing
  # on, at which point we assume it's a 404 because
  # no route has handled the request.
  @use app.router
###*
 * our custom "verbose errors" setting
 * which we can use in the templates
 * via settings['verbose errors']
 ###
app.enable "verbose errors"

###*
 * disable them in production
 * use $ NODE_ENV=production node server.js
 ###
app.disable "verbose errors"  if app.get("env") is "production"



###*  host dev files if in dev mode  ###
if app.get("env") is "development"
  app.use express.static(".tmp")
  app.use express.static("app")
else
  app.use express.static("dist")

app.use(express.directory(__dirname + '/doc'))
app.use(express.static(__dirname + '/doc'))

###*  Site Router   ###
require('./routes')(app)

###*  Start up both HTTP and HTTPS  ###
httpServer.listen app.locals.settings.port, app.locals.settings.IPAddress, ->
  console.log "HTTP server started on #{app.locals.settings.IPAddress}:#{app.locals.settings.port}"

httpsServer.listen app.locals.settings.sslPort, app.locals.settings.IPAddress, ->
  console.log "HTTPS server started on port #{app.locals.settings.IPAddress}:#{app.locals.settings.sslPort}"
