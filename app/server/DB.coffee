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

        console.log values
        _.each values, ( key, value ) ->
          that.client.hset database, value, key, redis.print

        console.log "saved to #{database}"
        callback database, key, values

exports.Database = new DB()
