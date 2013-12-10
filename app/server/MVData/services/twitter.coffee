"use strict"

#               require('twitter-oauth')
Service       = require('./utils/service')
StoreData     = require('./utils/storeData')
utils         = require('./utils/utils')
qs            = require('querystring')
TwitterAPI    = require('twitter-oauth')
_             = require('lodash')

###*
 * @namespace Twitter
###

_extendClient = ->
    @timeline = (params, oauthToken, oauthTokenSecret, callback) ->
        processData = (err, data, limit) ->
            callback err,
                limit: limit
                data: data

        if _.isObject(params)
            _params = qs.stringify(params)

        else if _.isString(params)
            _params = params

        else
            console.log "Twitter timeline requires params argument to either be a string or object"
            return false

        @fetch("https://api.twitter.com/1.1/statuses/user_timeline.json?#{_params}", oauthToken, oauthTokenSecret, processData)

###*
 * Instantiate the Twitter OAuth client
 *
 * @private
 * @param  {Object=} credentials  authenticated credentials
###
_oauthClientInit = (credentials) ->
    ###*  return if already exists  ###
    if @oauth2Client then return

    @oauth2Client = TwitterAPI
        consumerKey:            @consumerKey
        consumerSecret:         @consumerSecret
        domain:                 @config.base
        loginCallback:          @config.oauthPath
        oauthCallbackCallback:  _oauthSuccess.bind(@)

    _extendClient.call(@oauth2Client)

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
 * @param  {String}             name              Twitter users name
 * @param  {String}             accessToken
 * @param  {String}             accessTokenSecret
###
_oauthSuccess = (req, res, next, name, accessToken, accessTokenSecret) ->

    if @oauthHandleTokenCallback?
        @oauthHandleTokenCallback null,
            service: 'twitter'
            data:
                accessToken: accessToken
                accessTokenSecret: accessTokenSecret


module.exports = class Twitter extends Service

    constructor: (apiData, config) ->
        @consumerKey       = apiData['consumerKey']
        @consumerSecret    = apiData['consumerSecret']
        @accessToken       = null
        @accessTokenSecret = null

        super apiData, config

    ###*
     * The name of the service
     * @type {String}
    ###
    name: 'Twitter'

    ###*
     * Correllates to the service data passed in from services.json
     * @type {Object}
    ###
    servicesKey:
        'twitter_tweet': require('./actions/twitter_tweets')

    ###*
     * The view for initiating a twitter OAuth call.
     *
     * @public
     * @fires Twitter#oauthInit
     * @param  {Request}   req
     * @param  {Response}  res
     * @param  {Function}  next
    ###
    oauthInit: (req, res, next) ->
        _oauthClientInit.call(@)

        @oauth2Client.oauthConnect.apply this, arguments

    ###*
     * The view that handles the token returned from authorizing twitters app.
     * It will process that token, and make another request to google to fetch
     * the actual access token.
     *
     * @public
     * @fires Twitter#oauthHandleToken
     * @param  {Function}  callback
     * @param  {Request}   req
     * @param  {Response}  res
     * @param  {Function}  next     [description]
    ###
    oauthHandleToken: (callback, req, res, next) ->
        @oauthHandleTokenCallback = callback
        @oauth2Client.oauthCallback.apply this, [].slice.call(arguments, 1)

    ###*
     * Add access + refresh tokens to a twitter oauth client
     *
     * @public
     * @fires Twitter#addTokens
     * @params {Object} data An object containing `accessToken` and `accessTokenSecret` for Twitter
    ###
    addTokens: (data) ->
        ###*  return true so that the caller knows it reauthenticated successfully  ###
        return _oauthClientInit.call(@, data)

    ###*
     * Updates the services requestData with this one (most likely one from a DB)
     *
     * @public
     * @fires Twitter#configureRequest
     * @param  {String} service     the Twitter service to update
     * @param  {Object} requestData the actual requestData
    ###
    configureRequest: (service, requestData) ->
        @[service].configureRequest(JSON.parse requestData) if requestData?

    ###*
     * Returns the fields for the required this.addTokens properties
     *
     * @public
     * @fires Twitter#requiredTokens
     * @return {array}  the fields
    ###
    requiredTokens: ->
        ['accessToken', 'accessTokenSecret']


    ###*
     * Given a service with a callback, completes a data call. More options to come
     *
     * @public
     * @fires Twitter#initRequest
     * @params {Object} requestObj  the object which contains the service, callback & possible other options to come
     * @params {Object=} additionalParams  Additional parameters to extend the default params with
    ###
    initRequest: (requestObj, additionalParams) ->
        action =  @[requestObj.action]

        parseData = action.parseData.bind @, requestObj
        request = action.prepareAction(additionalParams)

        @oauth2Client[request.method](request.params, @accessToken, @accessTokenSecret, parseData)
