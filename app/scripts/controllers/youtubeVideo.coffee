'use strict'

myApp = window.myApp

serviceName = 'youtube'

_youtubeParams =
    width: 420
    height: 315
    videoId: null
    playerVars:
        'wmode':'opaque'
        'autoplay': 1
        'rel': 0
        'controls': 1
        'theme': 'light'
        'color': 'white'

myApp.controller 'youtubeVideo', ['$scope', '$sce', 'MVPlayer', ($scope, $sce, Player) ->
    $scope.playing = false
    $scope.state = null

    youtubeParams = _.clone(_youtubeParams)
    youtubeParams.videoId = $scope.item.id

    ###*
     * Instantiates this instance with the MVPlayer Service
     * 
     * @type {object}
     *       service: {string} - name of service (youtube)
     *       pId:     {string} - unique player instance id
     *       sId:     {string} - unique youtube instance id
    ###
    instanceParam = Player.initInstance(serviceName, $scope)

    $scope.instanceId = instanceParam.sId

    $scope.togglePlay = ->
        if @playing then Player.togglePlay(instanceParam) else @initMedia()

    $scope.initMedia = ->
        Player.initMedia instanceParam, "#{@instanceId}-vid", youtubeParams, (media) ->
            1
        , $scope
]