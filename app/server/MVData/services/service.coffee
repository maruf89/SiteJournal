module.exports = class Service
  constructor: ->

  name: 'undefined service'

  oauth:
    init: ->
      console.log "Missing oauth.init for #{@name}"

    handleToken: ->
      console.log "Missing oauth.handleToken for #{@name}"
