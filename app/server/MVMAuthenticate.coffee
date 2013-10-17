"use strict"

googleapis = require 'googleapis'
OAuth2Client = googleapis.OAuth2Client
request = require 'request'
db = require('./DB').Database
url = require 'url'
path = require 'path'
sslDomain = 'https://www.mariusmiliunas.com'

config =
    domain: null

serviceList = []


services =
    _8tracks:
        visible:
            name: '8tracks'
            api: null # will be added in the iteration below
        apiKey: '63eb25d5180ed975def1f62af625d1573e8826e6'
        init: ->
            curl = "curl --header 'X-Api-Key: #{services._8tracks.apiKey}' http://8tracks.com/mixes.xml"

    google:
        visible:
            name: 'Google'
            api: null
        clientId: '793238808427.apps.googleusercontent.com'
        clientSecret: 'F37f5_1HLwwLEOrYTafL-hBX'
        redirectUrl: "#{config.domain}oauth2callback"
        oauth2Client: null

        init: (req, res, next) ->
            this.oauth2Client = new OAuth2Client this.clientId,
                                                 this.clientSecret,
                                                 this.redirectUrl

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
                    console.log tokens
                    db.hsave 'api', 'google', tokens, (keys) ->
                        console.log keys
                        res.render 'jade/oauth/authenticated',
                            service: req.session.oauthService

    twitter:
        visible:
            name: 'Twitter'
            api: null
        consumerKey: 'NqgUDV2ETwpVlRHx0sqwnA'
        consumerSecret: 'uyDs2s4tf6JzjdEcrge0ANKxL4KPWtU2LeRcBunT60'
        accessToken: '198591770-yCHAkPiiSHameV53NVmYHZBMt92hIxo4usm1s30p'
        accessTokenSecret: 'CXi98cEwgXb9fZj06BeiWjJne6vDMwkUf4oRgAI25f0'
        twitterAuth: null

        init: ->
            this.twitterAuth = require( 'twitter-oauth' )
                consumerKey: this.consumerKey
                consumerSecret: this.consumerSecret
                domain: config.domain
                loginCallback: "oauth2callback"
                #completeCallback: "authenticate/success"
                oauthCallbackCallback: this.success

            this.twitterAuth.oauthConnect.apply this, arguments

        handleToken: ->
            this.twitterAuth.oauthCallback.apply this, arguments

        success: (req, res, next, name, accessToken, accessTokenSecret) ->
            console.log 'Twitter Auth Success!'
            tokens =
                name: name
                accessToken: accessToken
                accessTokenSecret: accessTokenSecret

            db.save 'api', twitter: tokens, (keys) ->
                console.log keys
                res.render 'jade/oauth/authenticated',
                    service: req.session.oauthService



for service of services
    visible = services[ service ].visible
    visible.api = service
    serviceList.push visible

console.log serviceList

class authenticate
    _this: null
    constructor: (domain) ->
        @_this = this
        config.domain = domain

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

