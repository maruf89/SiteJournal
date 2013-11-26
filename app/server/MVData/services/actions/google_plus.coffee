_           = require('lodash')
Action      = require('./google_action')

module.exports = class Plus extends Action
    service: 'plus'

    scope: 'https://www.googleapis.com/auth/plus.me'

    discover: ['plus', 'v1']

    defaultParams:
        'userId'    : 'me'
        'collection': 'public'
        'maxResults': 5
        'fields'    : 'items(object(attachments(content,fullImage/url,objectType,url),content,id,objectType),published,title,updated),nextPageToken,updated'

    action: 'activities'

    method: 'list'

    ###*
     * See notes in google_actions.coffee
     *
     * * IMPORTANT: Called as Google object NOT as Plus Action
    ###
    parseData: (requestObj, err, data) ->

        if err then return @requestCallback(requestObj, err)

        if data.items.length is 0
            return @requestCallback(requestObj, null, true)

        action = @[requestObj.action]

        ###*
         * If there's no currentRequest object, then we know we're searching through our entire history
         * and we're going backwards from the most recent.
         *
         * Second, we know that this is the first request, so the first returned item is the most recent.
        ###
        if data.updated
            if not action.currentRequest
                action.currentRequest = 'oldest'
                action.requestData.latestActivity = data.updated
            else
                ###*
                 * Since there's no way to query all posts after a certain date in plus, we have to check manually
                ###
                return @requestCallback(requestObj, null, true) if action.requestData.latestActivity is data.updated

        ###*  check if the last returned item is older than our oldest stored item, if so store it's datestamp  ###
        lastActivity = data.items[data.items.length - 1].published
        lastActivityTimestamp = (new Date(lastActivity)).getTime()

        if lastActivityTimestamp < action.oldestTimestamp
            action.requestData.oldestActivity = lastActivity
            action.oldestTimestamp = lastActivityTimestamp

        breakEarly = false

        ###*
         * Here we append the data until it's all complete
        ###
        data.items.forEach (item) ->
            ###*  check if we already have this item, if so break early  ###
            return false if breakEarly

            if action.requestData.latestActivity is item.published then breakEarly = true

            insertObj = 
                objectType: item.object.objectType

            insertObj.title       = item.title              if item.title

            insertObj.content     = item.object.content     if item.object.content
            insertObj.url         = item.object.url         if item.object.url
            insertObj.attachments = item.object.attachments if item.object.attachments

            action.storeData.items.insert (new Date(item.published)).getTime(), insertObj  

        if data.nextPageToken
            ###*  if there's a next page token, store it in the db in case it's the last successful request  ###
            action.requestData.oldestStamp = data.nextPageToken
            @request requestObj, pageToken: data.nextPageToken

        else
            ###*  Otherwise show that it's the end and return the callback  ###
            @requestCallback(requestObj)