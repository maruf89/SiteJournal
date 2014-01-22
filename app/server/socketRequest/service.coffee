"use strict"

_            = require('lodash')
db           = require('../DB')

module.exports = (socket) ->

    callback = socket.emit.bind(socket, 'receive service latest:all')

    socket.on 'send service latest:all', (data) ->
        offset = data.offset or 0
        end = data.num + offset

        db.zget('item', 'all', offset, end, callback, false, 'WITHSCORES')

    socket.on 'soundcloud update songLength', (data) ->
        duration = data.duration
        key      = data.key

        db.zupdate('item', 'all', key, {duration: duration}, (err, updates) ->
            # updates should = 1
        )
