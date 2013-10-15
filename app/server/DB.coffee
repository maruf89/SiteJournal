redis = require('redis')
_ = require('underscore')

class DB
    constructor: ->
        @client = redis.createClient()

    hsave: ( database, key, values, callback ) ->
        that = @

        if not callback
            console.log 'Callback Required.'
            return false

        database = "hash #{database}:#{key}"

        _.each values, ( value, key ) ->
          that.client.hset database, value, key, redis.print

        console.log "saved to #{database}"

exports.Database = new DB()
