### TO DO: build a functioning router that abstracts variables like `db` and `mvView` into a controller ###
module.exports = (app) ->

  # Include 404 and error configurations
  require('./config')(app)

  require('./authenticate')(app)

  #
  # * Routes
  #
  app.get "/", (req, res, next) ->
    # we use a direct database connection here
    # because the API would have sent JSON itself
    res.render 'index'

  #app.get "/ssl-gen", (req, res) ->
  #  do csrgen.sslGen
  #  res.render 'index'
  app.get "/query/:service/", (req, res, next) ->
    mvd.request req.params.service, {}, (err, res) ->
      console.log res

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


