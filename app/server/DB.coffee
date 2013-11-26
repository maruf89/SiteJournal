"use strict"

redis       = require 'redis'
_           = require 'lodash'

###*
 * Modifies the passed in databaseArgs object with it's new values
 *
 * @namespace DB
 * @private
 * @param {array} databaseArgs  the object that will be modified with the keys
 * @param {string/array} keys  a key, or an array of keys
 * @param {object/array} values  a value object, or an array of values
 ###
buildArguments = (databaseArgs, keys, values) ->
  if Array.isArray(keys) and Array.isArray(values)
    keys.forEach (key, index) ->
      databaseArgs.push(key, JSON.stringify values[index]) if values[index]?
  else
    databaseArgs.push(keys, JSON.stringify values)



###*
 * A Redis database
 *
 * @namespace DB
 ###
class DB
    constructor: ->
        @client = redis.createClient()

    ###*
     * Equivalent of Redis' SET
     *
     * @public
     * @fires DB#set
     * @param {string} database  the database inside hash to use
     * @param {string} key  the the key to use
     * @param {string/object} value  the value to save
     * @param {function=} (optional) callback  a completion callback
     #
     ###
    set: (database, key, value, callback = redis.print) ->
      database = "key #{database}:#{key}"

      if not _.isString(value) and not _.isNumber(value) then value = JSON.stringify(value)

      @client.set(database, value, callback)

    get: (database, key, callback) ->
      database = "key #{database}:#{key}"

      @client.get(database, callback)

    ###*
     * Equivalent of Redis' H{M}SET
     * Converts an object into a hash
     *
     * @public
     @ @fires DB#hsave
     * @param {string} database  the database inside hash to use
     * @param {string} section  the database section to query
     * @param {object} values  the data object to save
     * @param {function=} (optional) callback  a completion callback
     ###
    hsave: (database, section, values, callback = redis.print) ->
        database = "hash #{database}:#{section}"
        databaseArgs = [database]
        method = 'hmset'

        _.each values, (value, key) ->
          databaseArgs.push(key, value)

        ###  if only 1 key/value being set, use hset  ###
        method = if databaseArgs.length is 3 then 'hset' else 'hmset'

        databaseArgs.push(callback)
        @client[method].apply(@client, databaseArgs)

    ###*
     * Equivalent of Redis' HMGET/HGETALL
     *
     * @public
     * @fires DB#hgetAll
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

    ###*
     * Store sorted sets using Redis' ZADD
     * `values` will be JSON.stringify'ed
     *
     * @public
     * @fires DB#zadd
     * @param {string} database  the database inside hash to use
     * @param {string} section  the database section to query
     * @param {int/array} keys  either a single int, or an array of integer to serve as keys in the sorted list
     * @param {object/array} values  either a single object, or an array of objects as values. Will be stringified
     * @param {function=} callback  whatever is returned by Redis as a result of attempting the method
     ###
    zadd: (database, section, keys, values, callback = redis.print) ->
        database = "zset #{database}:#{section}"
        databaseArgs = [database]

        buildArguments(databaseArgs, keys, values)

        databaseArgs.push(callback)
        @client.zadd.apply(@client, databaseArgs)

    ###*
     * Retrieves items from a sorted set
     *
     * @public
     * @fires DB#zget
     * @param {String}   database  the database inside hash to use
     * @param {String}   section   the database section to query
     * @param {Integer}  from      the starting index
     * @param {Integer}  to        the end index
     * @param {Function} callback  whatever is returned by Redis as a result of attempting the method
     * @param {Boolean=} reversed  Whether to query results from the back
     ###
    zget: (database, section, from, to, callback, reversed = false) ->
        database = "zset #{database}:#{section}"
        method = if reversed then 'zrange' else 'zrevrange'

        console.log "@client.#{method}(#{database}, #{from}, #{to}, callback)"
        @client[method](database, from, to, callback)

    testZadd: ->
        database = 'test'
        section = database
        keys = []
        values = Array(6).join(0).split('').map (a,i) ->
            keys.push(i)
            name:'person - ' + i

        callback = (err) -> console.log arguments

        @zadd database, section, keys, values, callback

module.exports = new DB()
