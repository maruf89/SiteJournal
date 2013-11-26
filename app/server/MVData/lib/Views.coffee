"use strict"

url         = require 'url'
path        = require 'path'
_           = require 'lodash'

module.exports = class Views

  constructor: (@services) ->
    @servicesList = []

    _.each services, (data, serviceName) =>
      @servicesList.push serviceName

  servicesListView: (req, res, next) =>
    res.render 'jade/oauth/authenticate',
      services: @servicesList

  serviceView: (req, res, next) =>
    name = req.params.service
    req.session.oauthService = name

    service = @services[ name ]

    console.log "#{name} service requested"
    service.oauthInit.apply service, arguments

  tokenView: (callback, req) ->
    console.log req.session.oauthService + ' token returned'
    service = @services[req.session.oauthService]

    service.oauthHandleToken.apply service, arguments

  successView: ->
    res.render 'jade/oauth/authenticated',
      service: req.session.oauthService

