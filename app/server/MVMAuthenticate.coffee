"use strict"

googleapis = require 'googleapis'
OAuth2Client = googleapis.OAuth2Client
db = require './DBSave'
url = require 'url'
path = require "path"

services =


exports.MVMAuthenticate = class authenticate
    _this: null
    constructor: ->
        @_this = this

    init: (req, res) ->
        service = req.params.service

        res.render "jade/oauth"
            ,
            service: service
            serviceURL: @[ service ].init()
    
    handle: (req, res) ->
        urlParts = url.parse req.url, true
        query = urlParts.query

        console.log query

        res.render "index"

    google:
        init: ->
            clientId = '793238808427.apps.googleusercontent.com'
            clientSecret = 'F37f5_1HLwwLEOrYTafL-hBX'
            redirectUrl = 'https://localhost:9000/oauth2callback'

            oauth2Client = new OAuth2Client clientId, clientSecret, redirectUrl

            url = oauth2Client.generateAuthUrl
                access_type: 'offline'
                scope: 'https://gdata.youtube.com'