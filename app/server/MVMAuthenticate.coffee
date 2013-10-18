"use strict"

googleapis = require 'googleapis'
OAuth2Client = googleapis.OAuth2Client
request = require 'request'
db = require('./DB').Database
url = require 'url'
path = require 'path'

serviceData = require('../../services.json')
siteRedirect = process.env.ABSOLUTE_SSL_URL
serviceList = []


services =
    _8tracks:
        visible:
            name: '8tracks'
            api: null # will be added in the iteration below
        apiKey: serviceData['8tracks']['api-key']
        init: ->
            curl = "curl --header 'X-Api-Key: #{services._8tracks.apiKey}' http://8tracks.com/mixes.xml"

    google:
        visible:
            name: 'Google'
            api: null
        clientId: serviceData['Google']['clientId']
        clientSecret: serviceData['Google']['clientSecret']
        oauth2Client: null

        init: (req, res, next) ->
            this.oauth2Client = new OAuth2Client this.clientId,
                                                 this.clientSecret,
                                                 "#{siteRedirect}oauth2callback"

            url = this.oauth2Client.generateAuthUrl

                access_type: 'offline'
                scope: 'https://gdata.youtube.com'

            res.render 'jade/oauth/oauth',
                service: 'Google'
                serviceURL: url

        handleToken: (req, res, next) ->
            query = req.query

            this.oauth2Client.getToken query.code, (err, tokens) ->
                if err then console.log err
                else
                    console.log 'Token Success!'
                    db.hsave 'api', 'google', tokens, (keys) ->
                        res.render 'jade/oauth/authenticated',
                            service: req.session.oauthService

    twitter:
        visible:
            name: 'Twitter'
            api: null
        consumerKey: serviceData['Twitter']['consumerKey']
        consumerSecret: serviceData['Twitter']['consumerSecret']
        accessToken: serviceData['Twitter']['accessToken']
        accessTokenSecret: serviceData['Twitter']['accessToken']
        twitterAuth: null

        init: ->
            this.twitterAuth = require( 'twitter-oauth' )
                consumerKey: this.consumerKey
                consumerSecret: this.consumerSecret
                domain: siteRedirect
                loginCallback: "oauth2callback"
                oauthCallbackCallback: this.success

            this.twitterAuth.oauthConnect.apply this, arguments
            console.log this.twitterAuth

        handleToken: ->
            this.twitterAuth.oauthCallback.apply this, arguments

        success: (req, res, next, name, accessToken, accessTokenSecret) ->
            console.log 'Twitter Auth Success!'
            tokens =
                name: name
                accessToken: accessToken
                accessTokenSecret: accessTokenSecret

            db.hsave 'api', 'twitter', tokens, (keys) ->
                res.render 'jade/oauth/authenticated',
                    service: req.session.oauthService



for service of services
    visible = services[ service ].visible
    visible.api = service
    serviceList.push visible

console.log serviceList

class authenticate
    _this: null
    constructor:  ->
        @_this = this

    init: (req, res, next) ->
        res.render 'jade/oauth/authenticate',
            services: serviceList

    service: (req, res, next) ->
        name = req.params.service
        req.session.oauthService = name
        service = services[ name ]

        console.log "#{name} service requested"
        service.init.apply service, arguments

    token: (req, res, next) ->
        console.log req.session.oauthService + ' token returned'
        service = services[ req.session.oauthService ]

        service.handleToken.apply service, arguments

    success: (req, res) ->
        res.render 'jade/oauth/authenticated',
            service: req.session.oauthService

exports.MVMAuthenticate = new authenticate()

