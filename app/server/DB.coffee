"use strict"

redis       = require('redis')
_           = require('lodash')

_databaseKey = (type, database, section) ->
    string = "#{type} #{database}"

    if section then string += ":#{section}"

    return string

###*
 * Modifies the passed in databaseArgs object with it's new values
 *
 * @namespace DB
 * @private
 * @param  {array} databaseArgs  the object that will be modified with the keys
 * @param  {string/array} keys  a key, or an array of keys
 * @param  {object/array} values  a value object, or an array of values
 ###
_buildArguments = (databaseArgs, keys, values) ->

  if Array.isArray(keys) and Array.isArray(values)
    keys.forEach (key, index) ->
      databaseArgs.push(key, JSON.stringify(values[index])) if values[index]?

  else
    databaseArgs.push(keys, JSON.stringify(values))

###*
 * A Redis database
 *
 * @namespace DB
 * @class
 ###
class DB
    ###*
     * @constructor
    ###
    constructor: ->
        @client = redis.createClient()

    ###*
     * Equivalent of Redis' SET
     *
     * @public
     * @fires  DB#set
     * @param  {string} database  the database inside hash to use
     * @param  {string} key  the the key to use
     * @param  {string/object} value  the value to save
     * @param  {function=} (optional) callback  a completion callback
     #
     ###
    set: (database, key, value, callback = redis.print) ->
        dbKey = "key #{database}:#{key}"

        if not value or _.isFunction(value)
            return callback('Error: value must be set and not a function', null)

        if not _.isString(value) and not _.isNumber(value)
            value = JSON.stringify(value)

        @client.set(dbKey, value, callback)

    ###*
     * Equivalent of Redis' GET
     *
     * @public
     * @fires  DB#get
     * @param  {string}   database  the database inside hash to use
     * @param  {string}   key       the the key to use
     * @param  {Function} callback  callback with the value if exists
    ###
    get: (database, key, callback) ->
        dbKey = "key #{database}:#{key}"

        @client.get(dbKey, callback)

    ###*
     * Equivalent of Redis' DEL
     *
     * @public
     * @fires  DB#del
     * @param  {string}          database  the database inside hash to use
     * @param  {string/array}    key  the the key to use
     * @param  {Function=}       callback
    ###
    del: (database, key, callback = ->) ->
        args = []

        if _.isArray(key)
            args = key.map (keyVal) ->
                return "key #{database}:#{keyVal}"
        else
            args = ["key #{database}:#{key}"]

        args.push(callback)

        @client.del.apply(@client, args)

    ###*
     * Equivalent of Redis' H{M}SET
     * Converts an object into a hash
     *
     * @public
     * @fires  DB#hsave
     * @param  {string}    database  the database inside hash to use
     * @param  {string}    section   the database section to query
     * @param  {object}    values    the data object to save
     * @param  {function=} callback
     ###
    hsave: (database, section, key, value, callback = redis.print) ->
        dbKey = _databaseKey('hash', database, section)
        databaseArgs = [dbKey]

        if _.isString(key)
            if _.isFunction(value)
                return callback('Error: value required and cannot be a function', null)
            if value isnt 0 and _.isEmpty(value)
                return callback('Error: value is required', null)

            val = if _.isObject(value) then JSON.stringify(value) else value

            databaseArgs.push(key, val)

        else
            callback = if _.isFunction(value) then value else redis.print

            if not _.isObject(key)
                return callback('Error: key must be an object if arguments 3 & 4 are not objects', null)

            _.each key, (value, key) ->
                # omit functions
                return true if _.isFunction(key)

                if _.isObject(key) then key = JSON.stringify(key)

                databaseArgs.push(key, value)

        if databaseArgs.length is 1
            return callback('Error: key/value must be defined', null)

        ###  if only 1 key/value being set, use hset  ###
        method = if databaseArgs.length is 3 then 'hset' else 'hmset'

        databaseArgs.push(callback)
        @client[method].apply(@client, databaseArgs)

    ###*
     * Equivalent of Redis' HDEL/DEL
     *
     * deletes either a hash property, or the entire hash
     *
     * @public
     * @fires  DB#hdel
     * @param  {string}    database  the database inside hash to use
     * @param  {string}    section   the database section to query
     * @param  {property=} values    if no property included, the entire hash will be deleted
     * @param  {function}  callback
     ###
    hdel: (database, section, property, callback = redis.print) ->
        dbKey = _databaseKey('hash', database, section)
        method = 'hdel'
        databaseArgs = [dbKey]

        # if no property included
        if not property or _.isFunction(property)
            callback = property or redis.print
            method = 'del'

        else
            databaseArgs.push(property)

        databaseArgs.push(callback)

        @client[method].apply(@client, databaseArgs)


    ###*
     * Equivalent of Redis' HMGET/HGETALL
     *
     * @public
     * @fires  DB#hgetAll
     * @param  {string}   database  the database inside hash to use
     * @param  {string}   section   the database section to query
     * @param  {array=}   values    an optional array of keys
     * @param  {function} callback  to be used as response callback
     *                              callback returns an `array` of values if values was an array
     *                              Otherwise and object with prop:value
     ###
    hgetAll: (database, section, values, callback) ->
        dbKey = "hash #{database}:#{section}"
        args = []

        if _.isFunction(values)
            callback = values
            method = 'hgetall'

        else if _.isArray(values)
            method = 'hmget'
            args = values.slice(0)

        if not _.isFunction(callback)
            throw new TypeError('Callback required for DB#hgetAll', 'DB.coffee')

        args.unshift(dbKey)
        args.push(callback)
        @client[method].apply(@client, args)

    ###*
     * Store sorted sets using Redis' ZADD
     * `values` will be JSON.stringify'ed
     *
     * @public
     * @fires  DB#zadd
     * @param  {string} database  the database inside hash to use
     * @param  {string} section  the database section to query
     * @param  {int/array} keys  either a single int, or an array of integer to serve as keys in the sorted list
     * @param  {object/array} values  either a single object, or an array of objects as values. Will be stringified
     * @param  {function=} callback  whatever is returned by Redis as a result of attempting the method
     ###
    zadd: (database, section, keys, values, callback = redis.print) ->
        dbKey = "zset #{database}:#{section}"
        databaseArgs = [dbKey]

        _buildArguments(databaseArgs, keys, values)

        databaseArgs.push(callback)
        @client.zadd.apply(@client, databaseArgs)

    ###*
     * Retrieves items from a sorted set
     *
     * @public
     * @fires  DB#zget
     * @param  {String}   database  the database inside hash to use
     * @param  {String}   section   the database section to query
     * @param  {Integer}  from      the starting index
     * @param  {Integer}  to        the end index
     * @param  {Function} callback  whatever is returned by Redis as a result of attempting the method
     * @param  {Boolean=} reversed  Whether to query results from the back
     ###
    zget: (database, section, from, to, callback, reversed = false) ->
        dbKey = "zset #{database}:#{section}"
        method = if reversed then 'zrange' else 'zrevrange'

        console.log "@client.#{method}('#{dbKey}', #{from}, #{to}, callback)"
        @client[method](dbKey, from, to, callback)

    ###*
     * Given an array of keys, will remove them from a database
     *
     * @public
     * @fires  DB#zremKeys
     * @param  {String}    database  the database inside hash to use
     * @param  {String}    section   the database section to query
     * @param  {Array}     keys      array of integer keys
     * @param  {Function=} callback
    ###
    zremKeys: (database, section, keys, callback) ->
        dbKey = "zset #{database}:#{section}"

        keys.forEach (key) =>
            @client.zremrangebyscore(dbKey, key, key)

        console.log "Deleted #{keys.length} keys from #{database}:#{section}"

        do callback if callback

    ###*
     * Remove from a zset everything from a starting score (key integer) to end
     *
     * @public
     * @fires  DB#zremRangeByScore
     * @param  {String}    database  the database inside hash to use
     * @param  {String}    section   the database section to query
     * @param  {Integer}   from      the starting index
     * @param  {Integer}   to        the end index
     * @param  {Function=} callback
    ###
    zremRangeByScore: (database, section, from, to, callback = ->) ->
        dbKey = "zset #{database}:#{section}"

        @client.zremrangebyscore(dbKey, from, to, callback)

    ###*
     * Same as zremRangeByScore except remove by index, not score
     *
     * @public
     * @fires  DB#zremRangeByRank
     * @param  {String}    database  the database inside hash to use
     * @param  {String}    section   the database section to query
     * @param  {Integer}   from      the starting index
     * @param  {Integer}   to        the end index
     * @param  {Function=} callback
    ###
    zremRangeByRank: (database, section, from, to, callback = ->) ->
        dbKey = "zset #{database}:#{section}"

        @client.zremrangebyrank(dbKey, from, to, callback)

module.exports = x = new DB()
