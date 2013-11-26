myApp = window.myApp

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
    latest: (callback, num = 20, offset = 0) ->
        socket.on 'service latest:all', (err, latest) ->
            callback(JSON.parse(item) for item in latest if latest)

        socket.emit 'service latest:all',
            num: --num
            offset: offset
]
