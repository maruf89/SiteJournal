"use strict"

# https://github.com/ammmir/node-gdata
# https://developers.google.com/picasa-web/docs/2.0/developers_guide_protocol#Auth
# http://stackoverflow.com/questions/15183212/google-plus-album-urls

_                 = require('lodash')
GoogleAction      = require('./google_action')

module.exports = class Picasa extends GoogleAction
    service: 'picasa'

    scope: 'https://picasaweb.google.com/data'

    discover: ['', '']

    defaultParams:
        'userId': ''
        'collection': ''
        'fields': ''

    action: ''

    method: ''

    parseData: (requestObj, err, data) ->
        console.log data