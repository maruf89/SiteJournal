'use strict'

myApp = window.myApp

###*
 * Returns corresponding service url's
 * @type {Object}
###
sources =
    youtube: '//www.youtube.com/embed/__id__'

###*
 * Used to return corresponding main service colors
 * @type {Object}
###
bgColors =
    'youtube': '#C33333'
    'plus'   : '#53a93f'

offset = 0

myApp.controller 'MainCtrl', ['$scope', '$sce', 'fetcher', ($scope, $sce, fetcher) ->
    $scope.items = 
        list: []
        more: true

    $scope.trustSrc = (src) ->
        $sce.trustAsResourceUrl(src)

    $scope.buildSrc = (item) ->
        $scope.trustSrc(sources[item.type].replace('__id__', item.id))

    $scope.background = (type) ->
        "background-color": bgColors[type]

    fetcherCallback = (latest) ->
        console.log latest
        $scope.items.list = $scope.items.list.concat(latest)
        offset = $scope.items.list.length
        $scope.items.more = true

    $scope.loadMore = ->
        fetcher.latest(fetcherCallback, 20, offset)

    #$scope.loadMore(fetcherCallback)
]
