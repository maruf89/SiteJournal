"use strict"

_            = require('lodash')
db           = require('../DB')

module.exports = (socket) ->
    socket.on 'service latest:all', (data) ->
        callback = socket.emit.bind(socket, 'service latest:all')

        end = data.num + data.offset or 0

        db.zget('item', 'all', data.offset or 0, end, callback)
