"use strict"

_ = require('lodash')

module.exports = exports = class MVData
  constructor: (@serviceData, @config) ->
    @service = {}
    @serviceList = []

  init: (@serviceData, @config) ->
    _.each serviceData, (data, _service) =>
      _service = _service.toLowerCase()
      @serviceList.push(_service)
      @service[_service] = new (require("../services/#{_service}"))(data, config)

    @views = new (require('./Views'))( @service, @config )

  authenticateService: (service, data) ->
    @service[service].addTokens(data)

  request: (service, args, callback) ->
    @service[service].request(args, callback)
