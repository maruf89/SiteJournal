"use strict"

module.exports = (io) ->
    io.sockets.on 'connection', (socket) ->

        require('./service')(socket)
