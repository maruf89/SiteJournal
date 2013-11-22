myApp = window.myApp

myApp.factory 'socket', ($rootScope) ->
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