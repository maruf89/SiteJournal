"use strict"

_          = require('lodash')
mvd        = require('./MVData')
db         = require('./DB')

extendDefault = _.partialRight(_.assign, (a, b) ->
  b or a
)

###*
 * The module that queries services for data
 *
 * @namespace DataCollector
 * @public
 ###
class DataCollector
    currentService = null

    constructor: ->
        ###*  Hold all authenticated services in an array  ###
        @authenticatedServices = []

    ###*
     * Iterate through each service and check wether it contains
     * the required fields in the database
     *
     * @public
     * @fires DataCollector#configure
     ###
    configure: (@config, services) ->
        serviceLength = mvd.serviceList.length

        mvd.serviceList.forEach (name) =>
            name = name.toLowerCase()

            ###*  retrieve an array of the required keys  ###
            required = mvd.service[name].requiredTokens()

            db.hgetAll 'api', name, required, (err, res) =>

                if err
                    console.log err, name
                else
                    ###*  test that every statement is non falsey  ###
                    if (res.every (a) -> !!a)
                        ###*
                         * If the service is successfuly reauthenticated
                         * then push it to the list and go to next step of querying
                        ###
                        if mvd.service[name].addTokens(_.object(required, res))
                            @authenticatedServices.push(name)
                            @requestConfig(name)
                        else
                            console.log "Service #{name} failed to authenticate."
                    else
                        console.log "Service #{name} didn't return the required data to authenticate."

    requestConfig: (serviceName) ->
        service = @config.services[serviceName]

        if not service then return false

        service.actions.forEach (action) =>
            callback = @addRequestData.bind(@, serviceName, action)
            db.get('requestData', action, callback)

    addRequestData: (service, action, err, data) ->
        if err
            throw err

        mvd.service[service].configureRequest(action, data)

        @initRequest(service, action)

    initRequest: (service, action) ->
        action =
            action: action
            callback: @storeData

        mvd.service[service].request(action)

    ###*
     * Data request callback that will store specifically formatted data to the db
     * @fires DataCollector#storeData
     * @public
     * @param {error} err    an error object
     * @param {object} data
     ###
    storeData: (err, data) ->
        if err
            console.log err

        console.log data

        if not data.items.isEmpty
            ###*
             * Store all the data in the all list.
             * Each object has a reference to it's service, so that will be the glue to
             * it's own sorted data list defined below.
             ###
            db.zadd('item', 'all', data.items.keys, data.items.values)

            ###*  build out the keys/keys sorted data list for each service (value must be unique)  ###
            db.zadd('item', data.type, data.items.keys, data.items.keys)

        if data.requestData
            ###*  Simply update the old one with new truthy data  ###
            db.get 'requestData', data.type, (error, val) ->
                return false if error

                val = if val and _.isString(val) then JSON.parse(val) else {}

                ###*  Extend the existing object with only truthy values  ###
                db.set('requestData', data.type, extendDefault(val, data.requestData))

module.exports = new DataCollector()