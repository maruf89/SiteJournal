"use strict"

#
# * Express Dependencies
# http://howtonode.org/express-mongodb

domain = 'https://www.mariusmiliunas.com/'

fs = require 'fs'
http = require 'http'
https = require 'https'
express = require 'express'
coffee = require "coffee-script"
Oauth = require('./server/MVMAuthenticate').MVMAuthenticate
path = require "path"
oauth = new Oauth domain

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

# app.use(express.favicon());






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

# Since this is the last non-error-handling
# middleware use()d, we assume 404, as nothing else
# responded.

# $ curl http://localhost:3000/notfound
# $ curl http://localhost:3000/notfound -H "Accept: application/json"
# $ curl http://localhost:3000/notfound -H "Accept: text/plain"
app.use (req, res, next) ->
  res.status 404

  # respond with html page
  if req.accepts("html")
    res.render "404",
      url: req.url

    return

  # respond with json
  if req.accepts("json")
    res.send error: "Not found"
    return

  # default to plain-text. send()
  res.type("txt").send "Not found"


# error-handling middleware, take the same form
# as regular middleware, however they require an
# arity of 4, aka the signature (err, req, res, next).
# when connect has an error, it will invoke ONLY error-handling
# middleware.

# If we were to next() here any remaining non-error-handling
# middleware would then be executed, or if we next(err) to
# continue passing the error, only error-handling middleware
# would remain being executed, however here
# we simply respond with an error page.
app.use (err, req, res, next) ->

  # we may use properties of the error object
  # here and next(err) appropriately, or if
  # we possibly recovered from the error, simply next().
  res.status err.status or (err.status = 500)
  console.error "Server error catch-all says: ", err

  # prevent users from seeing specific error messages in production
  if app.get("env") isnt "development"
    newErr = new Error("Something went wrong. Sorry!")
    newErr.status = err.status
    err = newErr

  # respond with json
  if req.accepts("json")
    res.send
      data: err
      message: err.message

    return
  if req.accepts("html")
    res.render "errors",
      data: err
      message: err.message

    return

  # default to plain-text. send()
  res.type("txt").send "Error " + err.status


#
# * Routes
#
app.get "/", (req, res, next) ->
  # we use a direct database connection here
  # because the API would have sent JSON itself
  res.render 'index'

app.get "/ssl-gen", (req, res) ->
  do csrgen.sslGen
  res.render 'index'

app.get "/authenticate", oauth.init

app.get "/authenticate/success", oauth.success

app.get "/authenticate/:service", oauth.service

app.get "/oauth2callback", oauth.token

app.get "/:catchall", (req, res, next) ->
  res.render 'index'


#
# * Status Code pages
#
app.get "/404", (req, res, next) ->

  # trigger a 404 since no other middleware
  # will match /404 after this one, and we're not
  # responding here
  next()

app.get "/403", (req, res, next) ->

  # trigger a 403 error
  err = new Error("not allowed!")
  err.status = 403
  next err


app.get "/500", (req, res, next) ->

  # trigger a generic (500) error
  next new Error("keyboard cat!")

serverHTTP = http.createServer( app ).listen app.locals.settings.port, '173.234.60.108', ->
   console.log "HTTP server started on port #{app.locals.settings.port}"

serverHTTPS = https.createServer( options, app ).listen app.locals.settings.sslPort, '173.234.60.108', ->
  console.log "HTTPS server started on port #{app.locals.settings.sslPort}"

# app.listen app.locals.settings.port
