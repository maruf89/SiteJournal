"use strict"

_          = require('lodash')
mvd        = require('./MVData')
db         = require('./DB')

class DataCollector
  currentService = null

  constructor: ->
    ###*  Hold all authenticated services in an array  ###
    @authenticatedServices = []

  ###*
   * Iterate through each service and check wether it contains
   * the required fields in the database
   ###
  configure: (@config, services) ->
    serviceLength = mvd.serviceList.length
    requestDataReady = 0

    mvd.serviceList.forEach (name) =>
      name = name.toLowerCase()
      data = {}

      ###*  retrieve an array of the required keys   ###
      required = mvd.service[name].requiredTokens()

      db.hgetAll 'api', name, required, (err, res) =>
        if err then console.log err
        else
          ###*  test that every statement is non falsey  ###
          if (res.every (a) -> !!a)
            @authenticatedServices.push(name)
            ###*  combine the keys and values and pass to the service  ###
            mvd.service[name].addTokens(_.object(required, res))

        ###*  start requesting data as soon as all the services are done configing  ###
        if ++requestDataReady is serviceLength then do @requestData

  requestData: ->
    @config.order.forEach (service) =>
      if @authenticatedServices.indexOf(service) is -1 then return
      console.log "requestData(#{service})"
      mvd.service[service].request @storeData

  storeData: (data) ->
    console.log data

module.exports = new DataCollector()
