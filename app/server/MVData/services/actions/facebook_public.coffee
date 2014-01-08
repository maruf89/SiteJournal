"use strict"

_           = require('lodash')
Action      = require('./action')
utils       = require('../utils/utils')




###*
 * @namespace PublicPosts
 * Generate parameters for the request based on previous request data. Determines
 * whether to query only for the latest data, or to get the entire history.
https://graph.facebook.com/fql?q=SELECT+post_id,%20description,%20attachment,%20action_links,%20created_time,%20permalink,%20share_count+FROM+stream+WHERE+filter_key+=+%27others%27+AND+%20source_id+=+100000982720544+AND+privacy.value+=+%27EVERYONE%27+AND+created_time+%3C+1349666462+LIMIT+100&access_token=CAAIBU5on5r8BABRfe8cuBdH9ZCG3IXFP41ZCiCo6aEhnCV7NqBb9aKstaVHrCMkhlhqDdZB3aT1Tj2nV9sVUZCXIlYruIptcHlISOzHZCUtqOxkH9as1KgiatmjZBGWDGA7ZAKHn4ZACxJrEZAyFYt0iZCZBOvu3WSyaDagZB1gUZCDEiXuZAFAYKi3Uyi
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
        params.fql.created_at = " > #{@requestData.latestActivity}"

    ###*
     * If last request returned an error and we have the stamp from where we left off
     * then continue querying from there
    ###
    # if @requestData.error and @requestData.oldestActivity
    #     params.max_id = utils.decrement(@requestData.oldestActivity)

    ###*
     * Set now as the latest query timestamp
    ###
    @requestData.lastQuery = (new Date()).getTime()

    return params.fql

###*
 * @namespace PublicPosts
 * The action that gets and handles all tweets
###
module.exports = class PublicPosts extends Action

    service: 'facebook'

    display: 'facebook_public'

    apiMethod: 'graph'

    method: 'fql'

    defaultParams:
        fql:
            select: 'post_id, description, attachment, action_links, created_time, permalink, share_count'
            from: 'stream'
            where:
                source_id      : '= me()'
                filter_key     : "= 'others'"
                # type           : '= 80'
                'privacy.value': "= 'EVERYONE'"
                created_time   : '< now()'
            limit: 100
        mostRecent: false


    prepareAction: (additionalParams) ->
        params: _buildParams.call(@, additionalParams)
        apiMethod: @apiMethod
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