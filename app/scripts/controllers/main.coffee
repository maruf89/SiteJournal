'use strict'

myApp = window.myApp

myApp.controller 'MainCtrl', ($scope, socket) ->
	socket.on 'welcome', (message) ->
		console.log message

	socket.emit 'service latest:all'

	socket.on 'service latest:all', (err, latest) ->
		latest = (JSON.parse(item) for item in latest if latest)
		console.log(latest)