"use strict"

exports.twitter = class Twitter
    constructor: ->


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
