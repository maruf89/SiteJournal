"use strict"

appUri = process.env.APP_URI
db = require("#{appUri}/server/DB")

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