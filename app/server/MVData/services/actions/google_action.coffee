_       = require('lodash')

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
    params = _.clone(@defaultParams)

    _.extend(params, additionalParams) if additionalParams?

    ###*
     * If we reached the end, and we have the latestActivity timestamp
     * then search for only for the newest items by adding an additional second
     * because otherwise it will return the latest item which we already have
    ###
    if @requestData.end and @requestData.latestActivity
        @currentRequest = 'latest'
        newerDate = (new Date((new Date(@requestData.latestActivity)).getTime() + 1000)).toISOString()
        params.publishedAfter = newerDate

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
 * @namespace Action
 * Each Service under the immediate Google API umbrella such as Youtube and g+
 * are considered Actions because they're inside. They store their own
 * unique data inputs, but share the methods for storing data
###
module.exports = class Action
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
         * The Google client returned after executing a discovery
         * @type {Google Client}
        ###
        @client = null

    service: 'undefined'

    ###*
     * Adds request data to the action
     *
     * @param  {Object} requestData  data of previous queries
    ###
    configureRequest: (@requestData) ->
        @storeData.requestData = @requestData

        ###*  if the oldest activitiy's timestamp exists, set it as something more useable for future queries  ###
        if (@oldestTimestamp = @requestData.oldestActivity)
            @oldestTimestamp = (new Date(@oldestTimestamp)).getTime()


    ###*
     * Builds a request for this action with it's parameters
     *
     * @param  {Object=}      additionalParams  optional additional parameters
     * @return {ClientRequest}
    ###
    prepareAction: (additionalParams) ->
        params = _buildParams.call(@, additionalParams)

        @client[@service][@action][@method](params)

    ###*
     * @namespace Action/Google
     * Based on the response from google, will either run an error processing method
     * or continue parsing the action data to be returned
     *
     * IMPORTANT: Called as Google object NOT as Action
     *
     * @callback
     * @public
     * @fires Action#parseData
     * @param {Object} requestObj  the initial request object with callback and service info
     * @param {Object/null} err
     * @param {Object} data  response data pertaining to the action request
    ###
    parseData: ->
        console.log "Missing parseData method for #{@service}"
