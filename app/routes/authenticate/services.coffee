module.exports = (app, mvView) ->
  app.get "/authenticate/:service", mvView.serviceView
