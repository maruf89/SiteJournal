googleapis = require 'googleapis'
OAuth2Client = googleapis.OAuth2Client
youtubeConnect = require './youtubeConnect'
path = require "path"

exports.MVMAuthenticate = class authenticate
    _this: null
    constructor: ->
        @_this = this

    init: (req, res) ->
        _this = @_this
        service = req.params.service

        res.render 'jade/oauth',
            service: service
            serviceURL: _this[ service ].init()

    google:
        init: ->
            clientId: '793238808427.apps.googleusercontent.com'
            clientSecret: 'F37f5_1HLwwLEOrYTafL-hBX'
            redirectUrl: 'https://localhost:9000/oauth2callback'

            oauth2Client = new OAuth2Client google.clientId, google.clientSecret, google.redirectUrl

            url = oauth2Client.generateAuthUrl
                access_type: 'offline'
                scope: 'https://gdata.youtube.com'