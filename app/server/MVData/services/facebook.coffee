"use strict"

Service       = require('./utils/service')
qs            = require('querystring')
FacebookAPI   = require('facebook-sdk')
_             = require('lodash')


###*
 * Instantiate the Facebook OAuth client
 *
 * @private
 * @param  {Object=} credentials  authenticated credentials
###
_oauthClientInit = (credentials) ->
    ###*  return if already exists  ###
    if @oauth2Client then return

    @oauth2Client = new FacebookAPI
        appId:     @appId
        secret:    @appSecret

    ###*  store the credentials if they exist  ###
    if credentials
        @accessToken = credentials.accessToken
        @accessTokenSecret = credentials.accessTokenSecret

###*
 * The final callback with the oAuth Tokens
 *
 * @private
 * @callback
 * @param  {IncomingRequest}    req
 * @param  {OutgoingResponse}   res
 * @param  {Function}           next
 * @param  {String}             name              Facebook users name
 * @param  {String}             accessToken
 * @param  {String}             accessTokenSecret
###
_oauthSuccess = (req, res, next, name, accessToken, accessTokenSecret) ->

    if @oauthHandleTokenCallback?
        @oauthHandleTokenCallback null,
            service: 'facebook'
            data:
                accessToken: accessToken
                accessTokenSecret: accessTokenSecret


module.exports = class Facebook extends Service

    constructor: (apiData, config) ->
        super apiData, config

        @appId             = apiData['appId']
        @appSecret         = apiData['appSecret']
        @accessToken       = null
        @accessTokenSecret = null

    ###*
     * The name of the service
     * @type {String}
    ###
    name: 'Facebook'

    ###*
     * Correllates to the service data passed in from services.json
     * @type {Object}
    ###
    servicesKey:
        'facebook_tweet': require('./actions/facebook_public')

    ###*
     * The view for initiating a facebook OAuth call.
     *
     * @public
     * @fires Facebook#oauthInit
     * @param  {Request}   req
     * @param  {Response}  res
     * @param  {Function}  next
    ###
    oauthInit: (req, res, next) ->
        _oauthClientInit.call(@)

        @oauth2Client.oauthConnect.apply this, arguments

    ###*
     * The view that handles the token returned from authorizing facebooks app.
     * It will process that token, and make another request to google to fetch
     * the actual access token.
     *
     * @public
     * @fires Facebook#oauthHandleToken
     * @param  {Function}  callback
     * @param  {Request}   req
     * @param  {Response}  res
     * @param  {Function}  next     [description]
    ###
    oauthHandleToken: (callback, req, res, next) ->
        @oauthHandleTokenCallback = callback
        @oauth2Client.oauthCallback.apply this, [].slice.call(arguments, 1)

    ###*
     * Add access + refresh tokens to a facebook oauth client
     *
     * @public
     * @fires Facebook#addTokens
     * @params {Object} data An object containing `accessToken` and `accessTokenSecret` for Facebook
    ###
    addTokens: (data) ->
        ###*  return true so that the caller knows it reauthenticated successfully  ###
        return _oauthClientInit.call(@, data)

    ###*
     * Updates the services requestData with this one (most likely one from a DB)
     *
     * @public
     * @fires Facebook#configureRequest
     * @param  {String} service     the Facebook service to update
     * @param  {Object} requestData the actual requestData
    ###
    configureRequest: (service, requestData) ->
        @[service].configureRequest(JSON.parse requestData) if requestData?

    ###*
     * Returns the fields for the required this.addTokens properties
     *
     * @public
     * @fires Facebook#requiredTokens
     * @return {array}  the fields
    ###
    requiredTokens: ->
        ['accessToken', 'accessTokenSecret']


    ###*
     * Given a service with a callback, completes a data call. More options to come
     *
     * @public
     * @fires Facebook#initRequest
     * @params {Object} requestObj  the object which contains the service, callback & possible other options to come
     * @params {Object=} additionalParams  Additional parameters to extend the default params with
    ###
    initRequest: (requestObj, additionalParams) ->
        action =  @[requestObj.action]

        parseData = action.parseData.bind @, requestObj
        request = action.prepareAction(additionalParams)

        @oauth2Client[request.method](request.params, @accessToken, @accessTokenSecret, parseData)
