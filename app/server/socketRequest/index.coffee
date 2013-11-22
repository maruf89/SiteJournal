"use strict"

module.exports = (io) ->
    io.sockets.on 'connection', (socket) ->
        socket.emit 'welcome', 'Meroehut'

        require('./service')(socket)
