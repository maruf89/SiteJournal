Db = require('mongodb').Db
Connection = require('mongodb').Connection
Server = require('mongodb').Server
BSON = require('mongodb').BSON
ObjectID = require('mongodb').ObjectID

server_config = new Server 'localhost',
                            27017,
                                auto_reconnect: true
                                native_parser: true
class DB
    constructor: ->
        @db = new Db 'MVMDesign', server_config, safe: false
        @db.open ->

    save: ( collection, keys, callback ) ->
        if not callback
            console.log 'Callback Required.'
            return false
        @db.collection collection, ( err, keysColl ) ->
            if err then callback err
            else
                if not keys.length? then keys = [ keys ]

                keysColl.insert keys, ->
                    console.log "Successfully inserted into #{collection}"
                    callback null, keys

exports.Database = new DB()