"use strict"

_ = require('lodash')

module.exports = exports = class MVData
  constructor: () ->
    @service = {}
    @serviceList = []

  init: (@serviceData, @config) ->
    _.each serviceData, (data, _service) =>
      _service = _service.toLowerCase()
      @serviceList.push(_service)

      @service[_service] = new (require("../services/#{_service}"))(data, config)

    @views = new (require('./Views'))(@serviceList, @service)

  authenticated: (service) ->
    @service[service].authenticated = true