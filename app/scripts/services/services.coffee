myApp = window.myApp
num = 1

myApp.factory 'socket', ['$rootScope', ($rootScope) ->
    socket = io.connect('http://www.mariusmiliunas.com')

    on: (eventName, callback) ->
        socket.on eventName, ->
            args = arguments
            $rootScope.$apply ->
                console.log "Calling #{num++}"
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
        callback(JSON.parse(item) for item in latest if callback and latest)

    latest: (cb, num = 20, offset = 0) ->
        callback = cb

        socket.emit 'send service latest:all',
            num: --num
            offset: offset
]
