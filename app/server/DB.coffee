redis       = require 'redis'
_           = require 'lodash'

class DB
    constructor: ->
        @client = redis.createClient()

    ###*
     * @public
     * Equivalent of Redis' H{M}SET
     * Converts an object into a hash
     *
     * @param {string} database  the database inside hash to use
     * @param {string} section  the database section to query
     * @param {object} values  the data object to save
     * @param {function=} (optional) callback  a completion callback
     ###
    hsave: ( database, section, values, callback ) ->
        database = "hash #{database}:#{section}"
        databaseArgs = [database]
        method = 'hmset'

        _.each values, ( key, value ) ->
          databaseArgs.push(key, value)

        ###  if only 1 key/value being set, use hset  ###
        if databaseArgs.length is 3 then method = 'hset'

        databaseArgs.push(redis.print)
        @client[method].apply(@client, databaseArgs)

        console.log "saved to #{database}"
        callback database, section, values

    ###*
     * @public
     * Equivalent of Redis' HMGET/HGETALL
     *
     * @param {string} database  the database inside hash to use
     * @param {string} section  the database section to query
     * @param {array=} values  an optional array of keys
     * @param {function} callback  to be used as response callback
     ###
    hgetAll: ( database, section, values, callback ) ->
        database = "hash #{database}:#{section}"
        method = if _.isArray(values) then 'hmget' else 'hgetall'
        args = (values or []).slice(0) # if not already

        args.unshift(database)
        args.push(callback)
        @client[method].apply(@client, args)


module.exports = new DB()
