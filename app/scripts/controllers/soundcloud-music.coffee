'use strict'

myApp = window.myApp

serviceName = 'soundcloud'

initConfig =
    autoPlay: true
    useHTML5Audio: true
    debugMode: true

myApp.controller 'soundcloudMusic', ['$scope', 'MVPlayer', ($scope, Player) ->
    $scope.playing = false

    ###*
     * Instantiates this instance with the MVPlayer Service
     * 
     * @type {object}
     *       service: {string} - name of service (soundcloud)
     *       instance: {string} - unique player instance id
     *       serviceInstance: {string} - unique soundcloud instance id
    ###
    instanceParam = Player.initInstance(serviceName)

    $scope.togglePlay = ->
        if @playing then Player.togglePlay(instanceParam) else @initSong()

    $scope.initSong = ->
        Player.initSong instanceParam, "/tracks/#{@item.id}", initConfig, (sound) ->
            1
        , $scope
]