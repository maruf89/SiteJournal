"use strict"

_           = require('lodash')

###*
 * @namespace Action
###

###*
 * The base class for all actions
 * @type {Action}
###
module.exports = class Action
    constructor: (info) ->
        ###*
         * Set each passed in property as it's own
        ###
        _.each info, (val, key) =>
            @[key] = val

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
         * containe all prospective data sent from the action and be returned
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
         * Some services don't use timestamps to get items before/after others
         * this is just an alias to do the same thing
         * @type {Number}
         * @default Inf
        ###
        @oldestStamp = 1/0

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
     * Based on the response from the action, will either run an error processing method
     * or continue parsing the action data to be returned
     *
     * IMPORTANT: Called as Service object NOT as Action
     *
     * @callback
     * @public
     * @fires Action#parseData
     * @param {Object} requestObj  the initial request object with callback and service info
     * @param {Object} err
     * @param {Object} data  response data pertaining to the action request
    ###
    parseData: ->
        console.log "Missing parseData method for #{@service}"