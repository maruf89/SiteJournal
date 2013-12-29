"use strict"

_           = require('lodash')
Action      = require('./action')
utils       = require('../utils/utils')

###*
 * @namespace PublicPosts
 * Generate parameters for the request based on previous request data. Determines
 * whether to query only for the latest data, or to get the entire history.
 *
 * @private
 * @params {Object=} additionalParams   optional additional parameters
 * @return {Object}                     returns request parameters
###
_buildParams = (additionalParams) ->
    debugger
    fql = []

    _.each defaultParams.fql, (value, key) ->
        fql.push("#{key.toUpperCase()} #{value}")

    fql = fql.join(' ')

    params = _.clone(@defaultParams)

    _.extend(params, additionalParams) if additionalParams?

    ###*
     * If we reached the end, and we have the latestActivity timestamp
     * then search for only for the newest items by adding an additional second
     * because otherwise it will return the latest item which we already have
    ###
    if @requestData.end and @requestData.latestActivity
        @currentRequest = 'latest'
        params.since_id = @requestData.latestActivity

    ###*
     * If last request returned an error and we have the stamp from where we left off
     * then continue querying from there
    ###
    if @requestData.error and @requestData.oldestActivity
        params.max_id = utils.decrement(@requestData.oldestActivity)

    ###*
     * Set now as the latest query timestamp
    ###
    @requestData.lastQuery = (new Date()).getTime()

    return params

###*
 * @namespace PublicPosts
 * The action that gets and handles all tweets
###
module.exports = class PublicPosts extends Action

    service: 'facebook'

    display: 'facebook_public'

    method: 'graph'

    defaultParams:
        fql:
            select: 'post_id, description, attachment, action_links, created_time, permalink, share_count'
            from: 'stream'
            where: "source_id = me() AND type = 80 AND privacy.value = 'EVERYONE' AND created_time = now()"
            limit: 100
        mostRecent: false

    prepareAction: (additionalParams) ->
        params: _buildParams.call(@, additionalParams)
        method: @method

    ###
     * See notes in action.coffee
     *
     * * IMPORTANT Called as Service object NOT as Action
     *
     * @param  {Object} requestObj  the request object with service data + callback info
     * @param  {Error}  err         query error
     * @param  {Object} data        query response
    ###
    parseData: (requestObj, err, response) ->

        if err
            if err.limitReached
                console.log 'Rate limit reached'
            else
                console.log 'Facebook Request Error: ', err

            return @requestCallback(requestObj, err)

        data = response.data
        dataLength = data.length

        if not _.isArray(data)
            console.log 'Unknown Facebook data response type: ', data
            return @requestCallback(requestObj, err)

        # Reference this action since @ refers to the Facebook Object
        action = @[requestObj.action]

        # if no data passed back, or we already have the oldest item return saying it's done
        if dataLength is 0 or data[0].id_str is action.requestData.oldestActivity
            return @requestCallback(requestObj, null, true)

        ###*
         * If there's no currentRequest object, then we know we're searching through our entire history
         * and we're going backwards from the most recent.
         *
         * Second, we know that this is the first request, so the first returned item is the most recent.
         *
         * Else if - we reached the end and we're querying newer article
         * then the first item is the new latest
         ###
        if not action.currentRequest
            action.currentRequest = 'oldest'

            action.requestData.latestActivity = data[0].id_str

        else if action.requestData.end
            action.requestData.latestActivity = data[0].id_str

        ###*
         * check if the last returned item is older than our oldest stored item, if so store it's id
        ###
        lastActivity = data[dataLength - 1].id_str

        if lastActivity < action.oldestStamp
            action.requestData.oldestActivity = action.oldestTimestamp = lastActivity

        data.forEach (item) ->
            store =
                text: item.text
                id: item.id_str
                entities: item.entities

            store.geo = item.geo if item.geo?

            action.storeData.items.insert (new Date(item.created_at)).getTime(), store

        # if we have less items than the max limit, we know it's the end
        if data.length < action.defaultParams.count
            return @requestCallback(requestObj)

        ###*
         * Lastly continue querying going backwards
         * remove 1 from lastActivity so it doesn't return the same tweets
        ###
        @initRequest(requestObj, max_id: utils.decrement(lastActivity))