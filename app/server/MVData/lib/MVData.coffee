"use strict"

_ = require('lodash')

# Will store all callbacks to run whenever a service is authenticated
authCallbacks = []

# Will store which services are authenticated
authenticatedServices = []

class Service
    getAuthenticated: ->
        return authenticatedServices

    authenticatedCallback: (service) ->
        authCallbacks.forEach (fn) ->
            fn(service)

###*
* TODO: add deauthorize
###

module.exports = exports = class MVData
    constructor: () ->
        @service = new Service()
        @serviceList = []

    init: (@serviceData, @config) ->
        _.each serviceData, (data, _service) =>
            _service = _service.toLowerCase()
            @serviceList.push(_service)

            @service[_service] = new (require("../services/#{_service}"))(data, config)

        @views = new (require('./Views'))(@serviceList, @service)

    authenticated: (service) ->
        authenticatedServices.push(service)
        @service[service].authenticated = true
    
    onAuthenticate: (fn) ->
        authCallbacks.push(fn)