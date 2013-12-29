"use strict"

# Build base uri's and get required modules that
# are relative to it
appUri = process.env.APP_URI
db = require("#{appUri}/server/DB")

###*
 * The View that handles the initial OAuth success callback and
 * passes a successful service handshake authentication callback
 * 
 * @param  {Express}    app
 * @param  {MVDataView} mvView  View connector form MVData
###
module.exports = (app, mvView) ->
    app.get "/authenticate/oauth2callback", (req, res, next) ->
        callback = (err, data) ->

            if err
                res.render 'jade/error',
                    error: err
            else
                db.set 'api', data.service, data.data, ->
                    res.render 'jade/oauth/authenticated', service: data.service

        mvView.tokenView callback, req, res, next