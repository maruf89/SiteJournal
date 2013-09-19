"use strict"

googleapis = require 'googleapis'
OAuth2Client = googleapis.OAuth2Client
db = require('./DB').DB()
url = require 'url'
path = require 'path'

services =
    google:
        clientId: '793238808427.apps.googleusercontent.com'
        clientSecret: 'F37f5_1HLwwLEOrYTafL-hBX'
        redirectUrl: 'https://localhost:9000/oauth2callback'
        oauth2Client: null

        init: ->
            services.google.oauth2Client = new OAuth2Client services.google.clientId,
                                                            services.google.clientSecret,
                                                            services.google.redirectUrl
            
            url = services.google.oauth2Client.generateAuthUrl
                access_type: 'offline'
                scope: 'https://gdata.youtube.com'

        handleToken: (query) ->
            services.google.oauth2Client.getToken query.code, (err, tokens) ->
                if err then console.log err
                else
                    console.log 'Token Success!'
                    console.log tokens
                    db.save 'api', google: tokens

exports.MVMAuthenticate = class authenticate
    _this: null
    constructor: ->
        @_this = this

    init: (req, res) ->
        service = req.params.service
        req.session.oauthService = service

        res.render 'jade/oauth',
            service: service
            serviceURL: services[ service ].init()
    
    token: (req, res) ->
        query = req.query

        services[ req.session.oauthService ].handleToken query