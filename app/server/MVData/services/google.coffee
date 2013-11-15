"use strict"

Service       = require './service'
request       = require 'request'
googleapis    = require 'googleapis'
OAuth2Client  = googleapis.OAuth2Client

module.exports = class Google extends Service
  constructor: (apiData, @config) ->
    @clientId = apiData['clientId']
    @clientSecret = apiData['clientSecret']

  name: 'Google'

  oauthClientInit: ->
    ###*  return if already exists  ###
    if @oauth2Client then return

    @oauth2Client = new OAuth2Client @clientId,
                                     @clientSecret,
                                     @config.base + @config.oauthPath
    ###*  create a credentials object  ###
    @oauth2Client.credentials =
      access_token: null
      refresh_token: null

  ###*
   * The view for initiating a google OAuth call
   *
   * @params {request} req, res, next  the parameters passed in by an express request
   ###
  oauthInit: (req, res, next) ->
    do @oauthClientInit

    url = @oauth2Client.generateAuthUrl
      access_type: 'offline'
      scope: 'https://gdata.youtube.com'

    res.writeHead 301, Location: url
    res.end()

  ###*
   * The view that handles the token returned from authorizing googles app.
   * It will process that token, and make another request to google to fetch
   * the actual access token.
   *
   * @params {request} req, res, next  the parameters passed in by an express request
   ###
  oauthHandleToken: (callback, req, res, next) ->
    query = req.query

    @oauth2Client.getToken query.code, (err, tokens) ->
      if err
        console.log err
        callback err
      else
        console.log 'Token Success!'
        console.log tokens
        callback null, { service: 'google', data: tokens }

  ###*
   * Add access + refresh tokens to a google oauth client
   *
   * @params {object} data  an object containing `access_token` and `refresh_token` for youtube
   ###
  addTokens: (data) ->
    console.log 'requesting tokens.', data

    do @oauthClientInit
    @oauth2Client.credentials.access_token = data['access_token']
    @oauth2Client.credentials.refresh_token = data['refresh_token']

  ###*
   * Returns the fields for the required @addTokens properties
   *
   * @return {array}  the fields required for @addTokens
   ###
  requiredTokens: ->
    ['access_token', 'refresh_token']

  ###*
   * Given a callback, completes a youtube data call. More options to come
   *
   * @params {function} callback  the function to call with the youtube request response
   ###
  request: (callback) ->
    googleapis
      .discover('youtube', 'v3')
      .execute (err, client) =>
        client
          .youtube
          .activities
          .list(
            'part': 'snippet,contentDetails'
            'mine': 'true'
          )
          .withAuthClient(@oauth2Client)
          .execute(callback)
