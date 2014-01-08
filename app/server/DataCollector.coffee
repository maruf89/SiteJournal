"use strict"

_            = require('lodash')
mvd          = require('./MVData')
db           = require('./DB')

#  Add an action like 'youtube' or 'plus' and this will halt requests to that action
pause        = []

database     = 'item'
requestData  = 'requestData'

###*
 * Extends the object only with truthy values
 * Otherwise will not override a set truthy value with something like null or undefined
###
_extendDefault = _.partialRight(_.assign, (a, b) -> b or a)


###*
 * Processes the keys to be removed from the database:'all' for a specific service action
 * 
 * @callback
 * @private
 * @param  {String} action  The service action
 * @param  {Error}  err     error
 * @param  {Array}  keys    Array of keys return from the database
###
_processRemoval: (action, err, keys) ->
    return false if not _.isArray(keys)

    # Remove each individual key from the 'all' database for the action
    db.zremKeys database, 'all', keys, ->
        # Remove it's query requestData
        db.del(requestData, action)

        # Drop the action table
        db.zremRangeByRank database, action, 0, -1, ->
            console.log "All item data for #{action} has been successfully removed."

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
     * @param {Object} config  dataConfig file with the services and frequency
     ###
    configure: (@config) ->
        @frequency = config.frequency

        mvd.serviceList.forEach (name) =>
            name = name.toLowerCase()

            ###*  retrieve an array of the required keys  ###
            required = mvd.service[name].requiredTokens()

            db.get 'api', name, (err, res) =>
                if err
                    console.log err, name
                else
                    return if not res

                    res = JSON.parse(res)

                    ###*  Next verify that the returned object has the required fields  ###
                    auth = {}
                    req = []

                    required.forEach (key) ->

                        if res[key] then auth[key] = res[key]
                        else req.push key
                    
                    if req.length
                        console.log "#{name} doesn't have all oauth requirements, missing: ", req
                        return false

                    ###*
                     * If the service is successfuly reauthenticated
                     * then push it to the list and go to next step of querying
                    ###
                    if mvd.service[name].addTokens(auth)
                        @authenticatedServices.push(name)
                        @requestConfig(name)
                    else
                        console.log "Service #{name} failed to authenticate."
        #
        # Here should go a setTimeout frequency check
        # that checks over MVD's authenticated services
        # that checks for any new services that may have been authenticated since
        # 

        return @

    requestConfig: (serviceName) ->
        service = @config.services[serviceName]

        if not service then return false

        service.actions.forEach (action) =>
            if pause.indexOf(action) isnt -1 then return

            callback = @addRequestData.bind(@, serviceName, action)
            db.get(requestData, action, callback)

    addRequestData: (service, action, err, data) ->
        throw err if err

        mvd.service[service].configureRequest(action, data)

        @buildRequest(service, action)

    buildRequest: (service, action) ->
        actionObj =
            action: action
            parentService: service
            callback: @storeData

        @request(actionObj)

    request: (actionObj) ->
        mvd.service[actionObj.parentService].initRequest(actionObj)

        setTimeout(@request.bind(@, actionObj), @frequency)

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

        console.log data.items.values

        if not data.items.isEmpty
            ###*
             * Store all the data in the all list.
             * Each object has a reference to it's service, so that will be the glue to
             * it's own sorted data list defined below.
             ###
            db.zadd(database, 'all', data.items.keys, data.items.values)

            ###*  build out the keys/keys sorted data list for each service (value must be unique)  ###
            db.zadd(database, data.type, data.items.keys, data.items.keys)

        if data.requestData
            ###*  Simply update the old one with new truthy data  ###
            db.get requestData, data.type, (error, val) ->
                return false if error

                val = if val and _.isString(val) then JSON.parse(val) else {}

                ###*  Extend the existing object with only truthy values  ###
                db.set(requestData, data.type, _extendDefault(val, data.requestData))

    ###*
     * Removes all item data for every service:action from the database
     *
     * @public
     * @fires  DataCollector#cleanseAll
    ###
    cleanseAll: ->
        _.each @config.services, (d, service) ->
            service.actions.forEach (action) ->
                db.del(requestData, action)
                
                db.zremRangeByRank(database, action, 0, -1)

        db.zremRangeByRank(database, 'all', 0, -1)
        console.log "Cleansed all service data"

    ###*
     * Removes all item data for a single service action from the database
     * 
     * @public
     * @fires  DataCollector#cleanse
     * @param  {String} action  the service action to cleanse
    ###
    cleanse: (action) ->
        removalCB = _processRemoval.bind(@, action)
        db.zget(database, action, 0, -1, removalCB)

module.exports = new DataCollector()