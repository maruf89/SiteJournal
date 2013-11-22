"use strict"

_         = require('lodash')
db 		  = require('../DB')

module.exports = (socket) ->
	socket.on 'service latest:all', ->
		callback = socket.emit.bind(socket, 'service latest:all')
		db.zget('item', 'all', 0, 20, callback)
