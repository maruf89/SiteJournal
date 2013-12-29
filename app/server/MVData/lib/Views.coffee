"use strict"

url         = require 'url'
path        = require 'path'
_           = require 'lodash'

###*
 * Serves as a connector to services for OAuth purposes
 * 
 * @namespace MVDataViews
 * @class
###
module.exports = class MVDataViews
  ###*
   * @param  {Array}  @servicesList  Accepts an array of services
   * @param  {Object} @service       service => data - representation of the same services
  ###
  constructor: (@servicesList, @service) ->

  ###*
   * Renders the Services view for services to authenticate
   * 
   * @param  {IncomingRequest}    req
   * @param  {OutgoingResponse}   res
   * @param  {Function}           next
  ###
  servicesListView: (req, res, next) =>
    res.render 'jade/oauth/authenticate',
      services      : @servicesList
      authenticated : @authenticated

  ###*
   * Request service permissions
   * 
   * @param  {IncomingRequest}    req
   * @param  {OutgoingResponse}   res
   * @param  {Function}           next
  ###
  serviceView: (req, res, next) =>
    name = req.params.service
    req.session.oauthService = name

    service = @services[name]

    console.log "#{name} service requested"
    service.oauthInit.apply service, arguments

  ###*
   * After the token has been returned after accepting service specific permissions
   * 
   * @param  {IncomingRequest}    req
   * @param  {OutgoingResponse}   res
   * @param  {Function}           next
  ###
  tokenView: (callback, req) ->
    console.log req.session.oauthService + ' token returned'
    service = @services[req.session.oauthService]

    service.oauthHandleToken.apply service, arguments

  ###*
   * Optional success renderer
   * 
   * @param  {IncomingRequest}    req
   * @param  {OutgoingResponse}   res
  ###
  successView: (req, res) ->
    res.render 'jade/oauth/authenticated',
      service: req.session.oauthService

  serviceAuthenticated: (service) ->
    @service[service].authenticated = true
