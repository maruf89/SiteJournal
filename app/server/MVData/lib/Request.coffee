"use strict"

url         = require 'url'
path        = require 'path'
_           = require 'lodash'

module.exports = class Request

  constructor: (@services) ->
    @servicesList = []
