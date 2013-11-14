"use strict"

Service       = require './service'
request       = require 'request'
googleapis    = require 'googleapis'
OAuth2Client  = googleapis.OAuth2Client

module.exports = class Google extends Service
  oauth2Client =
    credentials:
      access_token: null
      refresh_token: null

  constructor: (apiData, @config) ->
    @clientId = apiData['clientId']
    @clientSecret = apiData['clientSecret']
    @accessToken = null

  name: 'Google'

  oauthInit: (req, res, next) ->
    @oauth2Client = new OAuth2Client @clientId,
                                     @clientSecret,
                                     @config.base + @config.oauthPath

    url = @oauth2Client.generateAuthUrl
      access_type: 'offline'
      scope: 'https://gdata.youtube.com'

    res.writeHead 301, Location: url
    res.end()

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

  addTokens: (data) ->
    console.log 'requesting tokens.', data
    oauth2Client.credentials.access_token = data['access_token']
    oauth2Client.credentials.refresh_token = data['refresh_token']

  requiredTokens: ->
    ['access_token', 'refresh_token']

  request: ->
    true
