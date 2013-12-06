"use strict"

Service         = require('./utils/service')
SoundCloudAPI   = require('soundclouder')
_               = require('lodash')

###*
 * Instantiate the Soundcloud OAuth client
 *
 * @namespace Soundcloud
 * @private
 * @param  {Object=} credentials  authenticated credentials
###
_oauthClientInit = (credentials) ->
    ###*  return if already exists  ###
    if @oauth2Client then return

    @oauth2Client = new SoundCloudAPI @clientId,
                                      @clientSecret,
                                      @config.base + @config.oauthPath

    ###*  create a credentials object if not passed in and set it  ###
    @oauth2Client.setToken(credentials.access_token) if credentials?

###*
 * @namespace Soundcloud
 * @class
###
module.exports = class Soundcloud extends Service
    ###*
     * @constructor
     * @param  {Object} apiData Soundcloud specific api data
     * @param  {Object} config  Env variables
    ###
    constructor: (apiData, config) ->
        @clientId = apiData['clientId']
        @clientSecret = apiData['clientSecret']

        super apiData, config

    ###*
     * The name of the service
     * @type {String}
    ###
    name: 'Soundcloud'

    ###*
     * Correllates to the service data passed in from services.json
     * @type {Object}
    ###
    servicesKey:
        'favorites': require('./actions/soundcloud_favorites')

    ###*
     * The view for initiating a soundcloud OAuth call. Will redirect to Soundclouds' auth URL
     *
     * @public
     * @fires Soundcloud#oauthInit
     * @param  {Request}   req
     * @param  {Response}  res
     * @param  {Function}  next
    ###
    oauthInit: (req, res, next) ->
        _oauthClientInit.call(@)

        url = @oauth2Client.getConnectUrl()
        console.log url

        res.writeHead 301, Location: url
        res.end()

    ###*
     * The view that handles the token returned from authorizing soundclouds app.
     * It will process that token, and make another request to soundcloud to fetch
     * the actual access token.
     *
     * @public
     * @fires Soundcloud#oauthHandleToken
     * @param  {Function}  callback
     * @param  {Request}   req
     * @param  {Response}  res
     * @param  {Function}  next     [description]
    ###
    oauthHandleToken: (callback, req, res, next) ->
        debugger
        query = req.query

        @oauth2Client.getToken query.code, (err, tokens) ->
            if err
                console.log err
                callback err
            else
                callback null, {service: 'soundcloud', data: tokens}

    ###*
     * Add access + refresh tokens to a soundcloud oauth client
     *
     * @public
     * @fires Soundcloud#addTokens
     * @params {Object} data An object containing `access_token` and `refresh_token` for Soundcloud
    ###
    addTokens: (data) ->
        ###*  return true so that the caller knows it reauthenticated successfully  ###
        return _oauthClientInit.call(@, data)

    ###*
     * Updates the services requestData with this one (most likely one from a DB)
     *
     * @public
     * @fires Soundcloud#configureRequest
     * @param  {String} action      the Soundcloud action to update
     * @param  {Object} requestData the actual requestData
    ###
    configureRequest: (action, requestData) ->
        @[action].configureRequest(JSON.parse requestData) if requestData?

    ###*
     * Returns the fields for the required this.addTokens properties
     *
     * @public
     * @fires Soundcloud#requiredTokens
     * @return {array}  the fields
    ###
    requiredTokens: ->
        ['access_token', 'refresh_token']


    ###*
     * Given a service with a callback, completes a data call. More options to come
     *
     * @public
     * @fires Soundcloud#initRequest
     * @params {Object} requestObj  the object which contains the service, callback & possible other options to come
     * @params {Object=} additionalParams  Additional parameters to extend the default params with
    ###
    initRequest: (requestObj, additionalParams) ->
        action =  @[requestObj.action]

        parseData = action.parseData.bind @, requestObj
        request = action.prepareAction(additionalParams)

        @oauth2Client[request.method](request.params, @accessToken, @accessTokenSecret, parseData)











