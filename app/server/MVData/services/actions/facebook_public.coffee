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

    if additionalParams?.fql
        _.extend(params, additionalParams.fql)

    ###*
     * If we reached the end, and we have the latestActivity timestamp
     * then search for only for the newest items by adding an additional second
     * because otherwise it will return the latest item which we already have
    ###
    if @requestData.end
        if @requestData.latestActivity
            @currentRequest = 'latest'
            params.fql.created_time = " > #{@requestData.latestActivity}"

    else
        params.fql.where.created_time = " < #{@oldestTimestamp}"

    if additionalParams?.tries
        params.fql.limit = @limit * (additionalParams.tries + 1)
    else
        params.fql.limit = @limit

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

_parseMedia =
    'photo': (media) ->
        src: media.src.replace(/(_)s(\.jpg)$/, "$1{s}$2") # wrap the size so we know which part is interchangeable for dif sizes
        fbid: media.photo.fbid
        type: media.type


###*
 * @namespace PublicPosts
 * The action that gets and handles all tweets
###
module.exports = class PublicPosts extends Action
    constructor: (info) ->
        super(info)

        @oldestTimestamp = (new Date()).getTime()

    service: 'facebook'

    display: 'facebook_public'

    apiMethod: 'graph'

    method: 'fql'

    defaultParams:
        fql:
            select: 'post_id, description, attachment, created_time, permalink, share_count'
            from: 'stream'
            where:
                source_id      : '= me()'
                filter_key     : "= 'others'"
                # type           : '= 80'
                'privacy.value': "= 'EVERYONE'"
        mostRecent: false

    ###*
     * Going back in histor, if no results are turned up, it will
     * increase the limit of possible return values by @limit
     * each time it retries up until this number
     * 
     * @type {Number}
    ###
    maxTries: 5

    limit: 50

    prepareAction: (additionalParams) ->
        params: _buildParams.call(@, additionalParams)
        apiMethod: @apiMethod
        method: @method
        tries: additionalParams?.tries or 0

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
        return @requestCallback(requestObj, err) if err

        data = response.data
        dataLength = data.length
        requestParams = requestObj.request.params
        fql = requestParams.fql

        if not _.isArray(data)
            console.log 'Unknown Facebook data response type: ', data
            return @requestCallback(requestObj, err)

        # Reference this action since @ refers to the Facebook Object
        action = @[requestObj.action]

        # if no data passed back, or we already have the oldest item return saying it's done
        if action.currentRequest is 'latest' and not dataLength
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

            action.requestData.latestActivity = data[0].created_time

        else if action.requestData.end
            action.requestData.latestActivity = data[0].created_time

        # If going back in time and no results
        if action.currentRequest is 'oldest'
            if dataLength
                requestObj.request.tries = 0

            else
                requestObj.request.tries = -~requestObj.request.tries # increments it

                # If we've tried up to the maximum number of retries
                if requestObj.request.tries is action.maxTries
                    return @requestCallback(requestObj)

                # else increment the current tries and limit and try again
                
                return @initRequest(requestObj, requestObj.request)

        ###*
         * check if the last returned item is older than our oldest stored item, if so store it's id
        ###
        lastActivity = data[dataLength - 1].created_time

        if lastActivity < action.oldestTimestamp
            action.requestData.oldestActivity = action.oldestTimestamp = lastActivity

        ###*
         * TODO: build out the FB parse data
         *
         * sample item:
         * {"post_id":"100000982720544_443027839099298","description":null,"attachment":{"media":[{"href":"http://www.youtube.com/watch?feature=player_embedded&v=mOE9fE72QLg","alt":"Rage Against The Machine-Killing In The Name(Less Angry Version)","type":"video","src":"https://fbexternal-a.akamaihd.net/safe_image.php?d=AQAeBa5ghFYM-Rhd&w=130&h=130&url=http%3A%2F%2Fi2.ytimg.com%2Fvi%2FmOE9fE72QLg%2Fmqdefault.jpg","video":{"display_url":"http://www.youtube.com/watch?v=mOE9fE72QLg","source_url":"http://www.youtube.com/v/mOE9fE72QLg?version=3&autohide=1&autoplay=1","source_type":"html"}}],"name":"Rage Against The Machine-Killing In The Name(Less Angry Version)","href":"http://www.youtube.com/watch?feature=player_embedded&v=mOE9fE72QLg","caption":"www.youtube.com","description":"Happy Holidays everybody!! Mixed by the very talented Grant Cornish http://grantcornish.com/ Instruments were arranged, played, and recorded by me. Buy me a ...","properties":[],"icon":"https://fbstatic-a.akamaihd.net/rsrc.php/v2/yj/r/v2OnaTyTQZE.gif"},"action_links":null,"created_time":1359180107,"permalink":"https://www.facebook.com/mmiliunas/posts/443027839099298","share_count":0}
        ###
        data.forEach (item) ->
            store =
                postId: item.post_id
                permalink: item.permalink

            # If it has a description (most don't) define it as that type
            if item.description
                if item.description.search(' shared ') isnt -1
                    store.type = 'share'
                else
                    store.type = item.description
            else
                store.type = 'post'

            if item.attachment?
                store.caption = item.attachment.caption if item.attachment.caption
                store.description = item.attachment.description if item.attachment.description
                store.title = item.attachment.name if item.attachment.name

                if item.attachment.media.length
                    if item.attachment.media.length > 1 then debugger
                    media = item.attachment.media[0]

                    if _parseMedia[media.type]
                        store.media = _parseMedia[media.type](media)
                    else
                        store.media = type: media.type


            action.storeData.items.insert item.created_time, store

        ###*
         * Lastly continue querying going backwards
         * remove 1 from lastActivity so it doesn't return the same tweets
        ###
        @initRequest(requestObj, requestObj.request)










