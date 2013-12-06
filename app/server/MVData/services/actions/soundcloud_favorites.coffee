_           = require('lodash')
Action      = require('./action')
utils       = require('../utils/utils')

module.exports = class Favorites extends Action
    ###*
     * This actions name
     * @type {String}
    ###
    service: 'favorites'

    ###*
     * This actions default query parameters
     * @type {Object}
    ###
    defaultParams:
        'some': 'param'

    ###
     * See notes in action.coffee
     *
     * * IMPORTANT Called as Service object NOT as Action
     * 
     * @param  {Object} requestObj  the request object with service data + callback info
     * @param  {Error}  err         query error
     * @param  {Object} data        query response
    ###
    parseData: (requestObj, err, data) ->

        if err then return @requestCallback(requestObj, err)

        if data.pageInfo.totalResults is 0
            return @requestCallback(requestObj, null, true)

        action = @[requestObj.action]

        ###*
         * If there's no currentRequest object, then we know we're searching through our entire history
         * and we're going backwards from the most recent.
         *
         * Second, we know that this is the first request, so the first returned item is the most recent.
         *
         * Else if - we reached the end and we're querying newer article
         * then the first item is the new latest
        ###
        if not action.currentRequest and data.pageInfo
            action.currentRequest = 'oldest'

            latestPublished = data.items[0].snippet.publishedAt
            action.requestData.latestActivity = latestPublished

        else if action.requestData.end
            latestPublished = data.items[0].snippet.publishedAt
            action.requestData.latestActivity = latestPublished

        ###*  check if the last returned item is older than our oldest stored item, if so store it's datestamp  ###
        lastActivity = data.items[data.items.length - 1].snippet.publishedAt
        lastActivityTimestamp = (new Date(lastActivity)).getTime()
        if lastActivityTimestamp < action.oldestTimestamp
            action.requestData.oldestActivity = lastActivity
            action.oldestTimestamp = lastActivityTimestamp

        ###*
         * Here we append the data until it's all complete
        ###
        data.items.forEach (item) ->

            unless item.snippet.type is 'like' then return false

            action.storeData.items.insert (new Date(item.snippet.publishedAt)).getTime(),
                title: item.snippet.title
                cover: item.snippet.thumbnails.high.url
                type: item.snippet.type
                id: item.contentDetails.like.resourceId.videoId

        if data.nextPageToken
            ###*  if there's a next page token, store it in the db in case it's the last successful request  ###
            action.requestData.oldestStamp = data.nextPageToken
            @request(requestObj, pageToken: data.nextPageToken)

        else
            ###*  Otherwise show that it's the end and return the callback  ###
            @requestCallback(requestObj)
