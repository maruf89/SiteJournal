_           = require('lodash')
Action      = require('./action')

###*
 * Generate parameters for the request based on previous request data. Determines
 * whether to query only for the latest data, or to get the entire history.
 * 
 * @namespace GoogleAction
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
 * Base class for Google Actions
 * Each Service under the immediate Google API umbrella such as Youtube and g+
 * are considered Actions because they're inside. They store their own
 * unique data inputs, but share the methods for storing data
 * 
 * @namespace GoogleAction
###
module.exports = class GoogleAction extends Action
    constructor: (info) ->
        # call parent constructor
        super info

        ###*
         * The Google client returned after executing a discovery
         * @type {GoogleClient}
        ###
        @client = null

    ###*
     * Builds a request for this action with it's parameters
     *
     * @param  {Object=}      additionalParams  optional additional parameters
     * @return {ClientRequest}
    ###
    prepareAction: (additionalParams) ->
        params = _buildParams.call(@, additionalParams)

        @client[@service][@action][@method](params)
