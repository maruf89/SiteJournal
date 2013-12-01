"use strict"

_            = require('lodash')
db           = require('../DB')

module.exports = (socket) ->

    callback = socket.emit.bind(socket, 'receive service latest:all')

    socket.on 'send service latest:all', (data) ->
        console.log "@socket call", data
        end = data.num + data.offset or 0

        db.zget('item', 'all', data.offset or 0, end, callback)
