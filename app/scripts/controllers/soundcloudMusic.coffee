'use strict'

myApp = window.myApp

serviceName = 'soundcloud'

initConfig =
    autoPlay: true
    useHTML5Audio: true
    useHighPerformance: true

whilePlaying = ($scope, Player) ->
    duration = $scope.item.duration
    current = (this.position or .001) / duration
    event = new CustomEvent("scWhile#{$scope.$id}", { detail: {current: current} })
    document.dispatchEvent(event)

onFinish = ($scope, Player) ->
    1

onSongLoaded = ($scope, socket) ->
    socket.emit('soundcloud update songLength', {
        service: 'souncloud'
        key: $scope.item.key
        duration: this.duration
    });
    console.log('loaded')

myApp.controller 'soundcloudMusic', ['$scope', 'MVPlayer', 'socket', ($scope, Player, socket) ->
    $scope.playing = false

    ###*
     * Instantiates this instance with the MVPlayer Service
     * 
     * @type {object}
     *       service: {string} - name of service (soundcloud)
     *       instance: {string} - unique player instance id
     *       serviceInstance: {string} - unique soundcloud instance id
    ###
    instanceParam = Player.initInstance(serviceName, $scope)

    _initConfig = _.clone(initConfig)

    if $scope.item.duration
        _initConfig.whileplaying = ->
            whilePlaying.apply(this, [$scope, Player])
    else
        _initConfig.onload = ->
            onSongLoaded.apply(this, [$scope, socket])

    $scope.togglePlay = ->
        if @playing then Player.togglePlay(instanceParam) else @initMedia()

    $scope.initMedia = ->
        Player.initMedia instanceParam, "/tracks/#{@item.id}", _initConfig, (sound) ->
            1
        , $scope
]