Db = require('mongodb').Db
Connection = require('mongodb').Connection
Server = require('mongodb').Server
BSON = require('mongodb').BSON
ObjectID = require('mongodb').ObjectID

class youtubeConnect
    constructor: ->
        this.db= new Db 'node-mongo-blog', new Server host, port, {auto_reconnect: true}, {}
        this.db.open ->

    save: ( keys, callback ) ->
        this.db.collection 'api', ( err, keysColl ) ->
            if err then callback err
            else
                if not keys.length? then keys = [ keys ]

                keysColl.insert keys, ->
                    callback null, keys

exports.youtubeConnect = youtubeConnect
