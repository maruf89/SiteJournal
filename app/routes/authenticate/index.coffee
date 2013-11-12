mvView = require("#{__dirname}/server/MVData").views

module.exports = (app) ->
  app.get "/authenticate", mvView.servicesListView

  app.get "/authenticate/success", mvView.successView

  app.get "/authenticate/:service", mvView.serviceView

  app.get "/oauth2callback", (req, res, next) ->
    callback = (err, data) ->
      if err
        res.render 'jade/error',
          error: err
      else
        db.hsave 'api', data.service, data.data, ->
          res.render 'jade/oauth/authenticated', service: data.service
    mvView.tokenView callback, req, res, next


