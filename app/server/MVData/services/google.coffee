"use strict"

Service       = require('./utils/service')
#request       = require('request')
googleapis    = require('googleapis')
_             = require('lodash')
OAuth2Client  = googleapis.OAuth2Client

###*
 * Instantiate the Google OAuth client
 *
 * @private
 * @param  {Object=} credentials  authenticated credentials
###
_oauthClientInit = (credentials) ->
    ###*  return if already exists  ###
    if @oauth2Client then return

    @oauth2Client = new OAuth2Client @clientId,
                                     @clientSecret,
                                     @config.base + @config.oauthPath

    ###*  create a credentials object if not passed in and set it  ###
    @oauth2Client.credentials = credentials or
        credentials =
            access_token: null
            refresh_token: null

module.exports = class Google extends Service
    constructor: (apiData, config) ->
        @clientId = apiData['clientId']
        @clientSecret = apiData['clientSecret']

        super apiData, config

    ###*
     * The name of the service
     * @type {String}
    ###
    name: 'Google'

    ###*
     * Correllates to the service data passed in from services.json
     * @type {Object}
    ###
    servicesKey:
        'youtube_like': require('./actions/google_youtube')
        'plus_post': require('./actions/google_plus')

    ###*
     * The view for initiating a google OAuth call. Will redirect to Googles' auth URL
     *
     * @public
     * @fires Google#oauthInit
     * @param  {Request}   req
     * @param  {Response}  res
     * @param  {Function}  next
    ###
    oauthInit: (req, res, next) ->
        _oauthClientInit.call(@)

        #  build the scopes
        scope = @actions.map( (service) =>
            @[service].scope
        ).join(' ')

        url = @oauth2Client.generateAuthUrl
            access_type: 'offline'
            scope: scope

        res.writeHead 301, Location: url
        res.end()

    ###*
     * The view that handles the token returned from authorizing googles app.
     * It will process that token, and make another request to google to fetch
     * the actual access token.
     *
     * @public
     * @fires Google#oauthHandleToken
     * @param  {Function}  callback
     * @param  {Request}   req
     * @param  {Response}  res
     * @param  {Function}  next     [description]
    ###
    oauthHandleToken: (callback, req, res, next) ->
        query = req.query

        @oauth2Client.getToken query.code, (err, tokens) ->
            if err
                console.log err
                callback err
            else
                @authenticated(tokens)
                callback null, {service: 'google', data: tokens}

    ###*
     * Add access + refresh tokens to a google oauth client
     *
     * @public
     * @fires Google#addTokens
     * @params {Object} data An object containing `access_token` and `refresh_token` for Google
    ###
    addTokens: (data) ->
        ###*  return true so that the caller knows it reauthenticated successfully  ###
        return _oauthClientInit.call(@, data)

    ###*
     * Add access tokens after oauth2Client has been initiated
     * 
     * @param  {[type]} data [description]
     * @return {[type]}      [description]
    ###
    authenticated: (data) ->
        if @oauth2Client
            @oauth2Client.credentials = data
        else
            _oauthClientInit.call(@, data)

    ###*
     * Updates the services requestData with this one (most likely one from a DB)
     *
     * @public
     * @fires Google#configureRequest
     * @param  {String} action      the Google action to update
     * @param  {Object} requestData the actual requestData
    ###
    configureRequest: (action, requestData) ->
        @[action].configureRequest(JSON.parse requestData) if requestData?

    ###*
     * Returns the fields for the required this.addTokens properties
     *
     * @public
     * @fires Google#requiredTokens
     * @return {array}  the fields
    ###
    requiredTokens: ->
        ['access_token', 'refresh_token']


    ###*
     * Given a service with a callback, completes a data call. More options to come
     *
     * @public
     * @fires Google#initRequest
     * @params {Object} requestObj  the object which contains the service, callback & possible other options to come
    ###
    initRequest: (requestObj) ->
        action =  @[requestObj.action]

        googleapis
            .discover.apply(googleapis, action.discover)
            .execute (err, client) =>
                if err
                    console.log err
                    return false

                action.client = client

                @request(requestObj)

    ###*
     * Once the client has been set, we can request freely
     *
     * @public
     * @fires Google#request
     * @param  {Object} requestObj         ---
     * @params {Object=} additionalParams  Additional parameters to extend the default params with
    ###
    request: (requestObj, additionalParams) ->
        action =  @[requestObj.action]

        parseData = action.parseData.bind @, requestObj
        request = action.prepareAction(additionalParams)

        request
            .withAuthClient(@oauth2Client)
            .execute(parseData)











