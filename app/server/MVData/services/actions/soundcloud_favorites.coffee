"use strict"

_           = require('lodash')
Action      = require('./action')
utils       = require('../utils/utils')

###*
 * @namespace Favorites
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
        params.since_id = @requestData.latestActivity

    ###*
     * Set now as the latest query timestamp
    ###
    @requestData.lastQuery = (new Date()).getTime()

    method: @method
    path: @path
    params: params

module.exports = class Favorites extends Action
    ###*
     * This actions name
     * @type {String}
    ###
    service: 'soundcloud'

    display: 'soundcloud_favorite'

    offset: 0

    method: 'get'

    path: '/users/{id}/favorites'

    ###*
     * This actions default query parameters
     * @type {Object}
    ###
    defaultParams:
        limit: 25
        format: 'json'

    prepareAction: (additionalParams) ->
        _buildParams.call(@, additionalParams)

    ###
     * Soundcloud does NOT store the timestamp of when you like an item. Since we cannot
     * effectively store that time, we use store it differently depending on whether we're
     * querying for the first time, or if we're just checking for the latest:
     *     All    - `created_at` field will be used as the date stamp
     *     Latest - the current (new Date()).getTime() will be used
     * 
     * Further notes see notes in action.coffee
     *
     * * IMPORTANT Called as Service object NOT as Action
     *
     * @param  {Object} requestObj  the request object with service data + callback info
     * @param  {Error}  err         query error
     * @param  {Object} data        query response
    ###
    parseData: (requestObj, err, data) ->
        
        if err
            if err.limitReached
                console.log 'Rate limit reached'
            else
                console.log 'Soundcloud Request Error: ', err

            return @requestCallback(requestObj, err)

        if not _.isArray(data)
            console.log 'Unknown Soundcloud data response type: ', data
            return @requestCallback(requestObj, err)

        # Reference this action since @ refers to the Soundcloud Object
        action = @[requestObj.action]
        dataLength = data.length

        # if no data passed back, or we already have the oldest item return saying it's done
        if dataLength is 0 or data[0].id is action.requestData.latestActivity
            return @requestCallback(requestObj, null, true)

        if not action.currentRequest
            ###*
             * If there's no currentRequest object, then we know we're searching through our entire history
             * and we're going backwards from the most recent.
             *
             * Second, we know that this is the first request, so store it's id
             ###
            action.currentRequest = 'oldest'

            action.requestData.latestActivity = data[0].id

        else if action.requestData.end
            ###*
             * Else if we're getting the latest and it passed the check below `dataLength` definition
             * then the first item must be new, so save it
            ###
            action.requestData.previousLatest = action.requestData.latestActivity
            action.requestData.latestActivity = data[0].id

        for index in [0...dataLength]
            item = data[index]

            store = {}

            # We store keys differently if searching for all items
            if action.currentRequest is 'oldest'
                key = (new Date(item.created_at)).getTime()

            else
                ###*
                 * Since these are not ordered by when we liked them, we have to compare each one
                 * to our latest id, and break if we already have it
                ###
                if item.id is action.requestData.previousActivity then break

                # Generate a current timestamp of our items (keep the correct order and give newer items higher stamps)
                key = (new Date()).getTime() + (index - dataLength) - dataLength

            store.artwork_url = item.artwork_url
            store.created_at  = item.created_at
            store.description = item.description
            store.id          = item.id
            store.title       = item.title
            store.permalink   = item.permalink_url

            action.storeData.items.insert(key, store);

        # if we have less items than the max limit, we know it's the end
        if dataLength < action.defaultParams.limit
            return @requestCallback(requestObj)

        action.offset += dataLength;

        ###*
         * Else continue querying going backwards
         * remove 1 from lastActivity so it doesn't return the same tweets
        ###
        @initRequest(requestObj, {offset: action.offset})
