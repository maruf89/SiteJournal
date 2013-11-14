"use strict"

appUri = process.env.APP_URI
mvView = require("#{appUri}/server/MVData").views

module.exports = (app) ->
  app.get "/authenticate", mvView.servicesListView

  require('./success')(app, mvView)

  require('./oauth2callback')(app, mvView)

  ### Services must be last because it has a :catchall  *###
  require('./services')(app, mvView)
