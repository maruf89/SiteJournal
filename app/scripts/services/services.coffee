'use strict'

myApp = window.myApp
num = 1

myApp.factory 'socket', ['$rootScope', ($rootScope) ->
    socket = io.connect('http://www.mariusmiliunas.com')

    on: (eventName, callback) ->
        socket.on eventName, ->
            args = arguments
            $rootScope.$apply ->
                callback.apply(socket, args)

    emit: (eventName, data, callback) ->
        socket.emit eventName, data, ->
            args = arguments
            $rootScope.$apply ->
                callback.apply(socket, args) if callback
]

myApp.factory 'fetcher', ['socket', (socket) ->
    callback = null

    socket.on 'receive service latest:all', (err, latest) ->
        if callback and latest
            items = for i in [0..(latest.length - 1)] by 2
                item = JSON.parse(latest[i])
                item.key = latest[i + 1]
                item

            callback(items)

    latest: (cb, num = 20, offset = 0) ->
        callback = cb

        socket.emit 'send service latest:all',
            num: --num
            offset: offset
]