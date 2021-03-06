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
     * @param {Array}  @servicesList  Accepts an array of services
     * @param {Object} @services      service => data - representation of the same services
    ###
    constructor: (@servicesList, @services) ->

    ###*
     * Renders the Services view for services to authenticate
     * 
     * @param {IncomingRequest}      req
     * @param {OutgoingResponse}     res
     * @param {Function}             next
    ###
    servicesListView: (req, res, next) =>
        res.render 'jade/oauth/authenticate',
            servicesList  : @servicesList
            services      : @services
            authenticated : @services.getAuthenticated()

    ###*
     * Request service permissions
     * 
     * @param {IncomingRequest}      req
     * @param {OutgoingResponse}     res
     * @param {Function}             next
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
     * @param {IncomingRequest}      req
     * @param {OutgoingResponse}     res
     * @param {Function}             next
    ###
    tokenView: (callback, req) ->
        console.log req.session.oauthService + ' token returned'
        service = @services[req.session.oauthService]

        service.oauthHandleToken.apply service, arguments

    ###*
     * Success renderer
     * 
     * @param {IncomingRequest}      req
     * @param {OutgoingResponse}     res
     * @param {Function}             next
    ###
    successView: (req, res, next) ->
        @services.authenticatedCallback(req.session.oauthService)

        res.render 'jade/oauth/authenticated',
            service: req.session.oauthService
