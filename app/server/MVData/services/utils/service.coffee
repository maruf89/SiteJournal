module.exports = class Service
    constructor: ->
        do @buildRequestData

        @storeData =
            type: null
            items: []
            requestData: @requestData

    name: 'undefined service'

    ###*
     * Builds a requestData object
     *
     * lastQuery      - timestamp of the last request attempt
     * end            - whether the service has queried to the end
     * latestActivity - the ISO date stamp of the latest returned object
     * oldestActivity - the ISO date stamp of the oldest returned object
     * request        - the parameters object of the last request
     * error          - the error object returned with the last request
    ###
    buildRequestData: ->
        @requestData =
            lastQuery:      null
            end:            false
            latestActivity: null
            oldestActivity: null
            request:        null
            error:          null

    oauthClientInit: ->
        console.log "Missing oauthClientInit method for #{@name}"

    oauthInit: ->
        console.log "Missing oauthInit method for #{@name}"

    oauthHandleToken: ->
        console.log "Missing oauthHandleToken method for #{@name}"

    addTokens: ->
        console.log "Missing addTokens method for #{@name}"

    requiredTokens: ->
        console.log "Missing requiredTokens method for #{@name}"

    request: ->
        console.log "Missing request method for #{@name}"

    parseData: ->
        console.log "Missing parseData method for #{@name}"

    ###*
     * The callback proxy for each service
     *
     * @param  {Object}  requestObj  the request Object passed in to the initial request
     * @param  {Error=}  error       any errors if passed
     * @param  {Boolean} empty       Whether the request returned an empty result 
    ###
    requestCallback: (requestObj, error, empty) ->
        if error
            @requestData.error = error

        action = @[requestObj.action]

        ###*  It's possible thatthe last query returned no results but the previous ones did  ###
        if empty and action.storeData.items.isEmpty
            console.log "No #{requestObj.action} results"
            return false

        console.log "Fetch #{action.storeData.items.length} items for #{requestObj.action}"

        action.requestData.end = true

        ###*  Finally call the callback with whatever's in @storeData  ###
        requestObj.callback(error, action.storeData)

        action.storeData.items.empty()
