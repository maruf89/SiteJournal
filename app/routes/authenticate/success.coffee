module.exports = (app, mvView) ->
  app.get "/authenticate/success", mvView.successView
