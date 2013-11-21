"use strict"

Service       = require './utils/service'
StoreData     = require './utils/storeData'
request       = require 'request'
googleapis    = require 'googleapis'
_             = require 'lodash'
OAuth2Client  = googleapis.OAuth2Client

###*
 * @namespace Action
 * Each Service under the immediate Google API umbrella such as Youtube and g+
 * are considered Actions because they're inside. They store their own
 * unique data inputs, but share the methods for storing data
###
class Action
    constructor: (info) ->
        ###*
         * Set each passed in property as it's own
        ###
        _.each info, (@val, @key) =>

        ###*
         * To tell whether we are querying only the most recent items, or the entire history
         * Will one of:
         *     'latest'
         *     'oldest'
         * @type {String}
         * @default null
        ###
        @currentRequest = null

        ###*
         * The container for all Action specific data that will
         * containe all prospective data sent from google and be returned
         * to the callback
         * @type {Object}
        ###
        @storeData = null

        ###*
         * Timestamp of the oldest returned requested item. Set to infinity if it doesn't get overwritten later.
         * @type {Number}
         * @default Inf
        ###
        @oldestTimestamp = 1/0

    ###*
     * Adds request data to the action
     * 
     * @param  {Object} requestData  data of previous queries
    ###
    configureRequest: (@requestData) ->
        ###*  if the oldest activitiy's timestamp exists, set it as something more useable for future queries  ###
        if (@oldestTimestamp = @requestData.oldestActivity)
            @oldestTimestamp = (new Date(@oldestTimestamp)).getTime()

class Youtube extends Action
    scope: 'https://gdata.youtube.com'

    discover: ['youtube', 'v3']

    defaultParams:
        'part': 'snippet,contentDetails'
        'mine': true
        'fields': 'items(contentDetails,snippet),nextPageToken,pageInfo,tokenPagination'

    ###*
     * Builds a request for this action with it's parameters
     * 
     * @param  {GoogleClient} client            the passed in client object from googleapis
     * @param  {Object=}      additionalParams  optional additional parameters
     * @return {ClientRequest}
    ###
    prepareAction: (client, additionalParams) ->
        params = _buildParams.call(@, additionalParams)

        client
            .youtube
            .activities
            .list(params)



class Plus extends Action
    scope: 'https://www.googleapis.com/auth/plus.me'

    discover: ['plus', 'v3']

    defaultParams:
        'userId': 'me'

    prepareAction: (client, additionalParams) ->
        params = _buildParams.call(@, additionalParams)
        console.log client
        client
            .plus
            .people
            .get(params)

###*
 * Correllates to the service data passed in from services.json
 * @type {Object}
###
servicesKey =
    'youtube': Youtube
    'plus': Plus

###*
 * When a request is called, will contain the service object that is passed in
 * @type {Object}
 * @default null
###
currentService = null

###*
 * @namespace Action
 * Generate parameters for the request based on previous request data. Determines
 * whether to query only for the latest data, or to get the entire history.
 *
 * @private
 * @params {Object=} additionalParams   optional additional parameters
 * @return {Object}                     returns request parameters
###
_buildParams = (additionalParams) ->
    params = @defaultParams

    _.extend(params, additionalParams) if additionalParams?

    ###*
     * If we reached the end, and we have the latestActivity timestamp
     * then search for only for the newest items
    ###
    if @requestData.end and @requestData.latestActivity
        currentRequest = 'latest'
        params.publishedAfter = @requestData.latestActivity

    ###*
     * If last request returned an error and we have the stamp from where we left off
     * then continue querying from there
    ###
    if @requestData.error and @requestData.oldestActivity
        params.publishedBefore = @requestData.oldestActivity

    ###*
     * Set now as the latest query timestamp
    ###
    @requestData.lastQuery = (new Date()).getTime()

    return params

###*
 * @namespace Google
 * Based on the response from google, will either run an error processing method
 * or continue parsing the action data to be returned
 *
 * @callback
 * @private
 * @param {Object} requestObj
 * @param {Object/null} err
 * @param {Object} data  response data pertaining to the action request
###
_parseData = (requestObj, err, data) ->
    if err then return @requestCallback(requestObj, err)

    # TODO figure out why youtube is still requseting the entire history
    console.log err
    console.log data
    return false
    action = @[requestObj.action]

    ###*
     * If there's no currentRequest object, then we know we're searching through our entire history
     * and we're going backwards from the most recent.
     *
     * Second, we know that this is the first request, so the first returned item is the most recent.
     ###
    if not currentRequest and data.pageInfo
        action.currentRequest = 'oldest'
        ###*  add 1 second to the latest activity so we don't return the same latest object  ###
        latestPublished = (new Date((new Date(data.items[0].snippet.publishedAt)).getTime() + 1000)).toISOString()
        action.requestData.latestActivity = latestPublished

    ###*  check if the last returned item is older than our oldest stored item, if so store it's datestamp  ###
    lastActivity = data.items[data.items.length - 1].snippet.publishedAt
    lastActivityTimestamp = (new Date(lastActivity)).getTime()
    if lastActivityTimestamp < oldestTimestamp
        action.requestData.oldestActivity = lastActivity
        oldestTimestamp = lastActivityTimestamp

    ###*
     * Here we append the data until it's all complete
    ###
    data.items.forEach (item) ->
        unless item.snippet.type is 'like' then return false

        action.storeData.items.insert (new Date(item.snippet.publishedAt)).getTime(),
            title: item.snippet.title
            thumb: item.snippet.thumbnails.default.url
            type: item.snippet.type
            id: item.contentDetails.like.resourceId.videoId

    if data._nextPageToken
        ###*  if there's a next page token, store it in the db in case it's the last successful request  ###
        action.requestData.oldestStamp = data.nextPageToken
        @request requestObj, pageToken: data.nextPageToken

    else
        ###*  Otherwise show that it's the end and return the callback  ###
        action.requestData.end = true
        @requestCallback(requestObj)

module.exports = class Google extends Service
    constructor: (apiData, @config) ->
        @clientId = apiData['clientId']
        @clientSecret = apiData['clientSecret']

        ###*
         * Will store the keys of all the google services
         * @type {Array}
        ###
        @services = []

        ###*
         * Iterate over each passed in service and create references for each
        ###
        _.each apiData.services, (serviceInfo, name) =>
            @services.push(name)
            @[name] = new servicesKey[name](serviceInfo)

            ###*
             * Set storeData for each service.
             * Will be the final returned object for this services' data
             * after querying google for it and after parsing
             * @type {StoreData}
            ###
            @[name].storeData = new StoreData(name, @buildRequestData.call(@[name]))

        return @

    ###*
     * The name of the service
     * @type {String}
    ###
    name: 'Google'

    ###*
     * Instantiate the Google OAuth client
     *
     * @param  {Object=} credentials authenticated credentials
    ###
    oauthClientInit: (credentials) ->
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

    ###*
     * The view for initiating a google OAuth call. Will redirect to Googles' auth URL
     *
     * @param  {Request}   req
     * @param  {Response}  res
     * @param  {Function}  next
    ###
    oauthInit: (req, res, next) ->
        do @oauthClientInit

        scope = @services.map( (service) =>
            @[service].scope
        ).join(' ')
        console.log scope

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
                console.log 'Token Success!'
                console.log tokens
                callback null, { service: 'google', data: tokens }

    ###*
     * Add access + refresh tokens to a google oauth client
     *
     * @params {Object} data An object containing `access_token` and `refresh_token` for Google
    ###
    addTokens: (data) ->
        ###*  return true so that the caller knows it reauthenticated successfully  ###
        return @oauthClientInit(data)

    ###*
     * Updates the services requestData with this one (most likely one from a DB)
     *
     * @public
     * @fires Google#configureRequest
     * @param  {String} service     the Google service to update
     * @param  {Object} requestData the actual requestData
    ###
    configureRequest: (service, requestData) ->
        @[service].configureRequest(JSON.parse requestData) if requestData?

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
     * @fires Google#request
     * @params {Object}  service           the object which contains the service, callback & possible other options to come
     * @params {Object=} additionalParams  Additional parameters to extend the default params with
    ###
    request: (requestObj, additionalParams) ->
        action =  @[requestObj.action]

        googleapis
            .discover.apply(googleapis, action.discover)
            .execute (err, client) =>
                if err
                    console.log err
                    return false

                parseData = _parseData.bind @, requestObj
                request = action.prepareAction(client, additionalParams)

                request
                    .withAuthClient(@oauth2Client)
                    .execute(parseData)
                










