"use strict"

# Need new Facebook api
# https://developers.facebook.com/docs/facebook-login/manually-build-a-login-flow/

Service       = require('./utils/service')
qs            = require('querystring')
FacebookAPI   = require('./utils/facebook-node')
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

    params =
        appId           : @appId
        secret          : @appSecret
        redirect_uri    : @config.base + @config.oauthPath
        domain          : @config.cookieDomain

    params.credentials = credentials if credentials?

    @oauth2Client = new FacebookAPI(params)

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
    ###*
     * @constructor
     * @param  {Object} apiData  Object with the necessary API keys
     * @param  {Object} config   Site specific configuration keys
    ###
    constructor: (apiData, config) ->
        @appId             = apiData.appId
        @appSecret         = apiData.appSecret
        @accessToken       = null
        @accessTokenSecret = null

        super apiData, config

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
        'facebook_public': require('./actions/facebook_public')

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

        url = @oauth2Client.getLogin
            scope: 'read_stream, user_status'

        res.writeHead 301, Location: url
        res.end()

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
        code = req.query.code

        @oauth2Client.getToken code, (err, response) ->
            callback err if err

            callback null,
                service: 'facebook'
                data: response

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
        ['access_token']

    ###*
     * Given a service with a callback, completes a data call. More options to come
     *
     * @public
     * @fires Facebook#initRequest
     * @params {Object} requestObj  the object which contains the service, callback & possible other options to come
     * @params {Object=} additionalParams  Additional parameters to extend the default params with
     *
     * https://graph.facebook.com/fql?q=SELECT+post_id,description,privacy,actor_id,action_links,app_data,created_time,attribution,message+FROM+stream+WHERE+filter_key+=+%27others%27+AND+%20source_id+=+100000982720544&access_token=CAAIBU5on5r8BABRfe8cuBdH9ZCG3IXFP41ZCiCo6aEhnCV7NqBb9aKstaVHrCMkhlhqDdZB3aT1Tj2nV9sVUZCXIlYruIptcHlISOzHZCUtqOxkH9as1KgiatmjZBGWDGA7ZAKHn4ZACxJrEZAyFYt0iZCZBOvu3WSyaDagZB1gUZCDEiXuZAFAYKi3Uyi
    ###
    initRequest: (requestObj, additionalParams) ->
        action =  @[requestObj.action]

        parseData = action.parseData.bind @, requestObj
        request = action.prepareAction(additionalParams)

        @oauth2Client[request.apiMethod](request.method, request.params, parseData)
