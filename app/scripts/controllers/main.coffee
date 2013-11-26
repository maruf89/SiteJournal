'use strict'

myApp = window.myApp

sources =
    youtube: '//www.youtube.com/embed/__id__'

myApp.controller 'MainCtrl', ['$scope', '$sce', 'fetcher', ($scope, $sce, fetcher) ->
    $scope.items = {}

    $scope.trustSrc = (src) ->
        $sce.trustAsResourceUrl(src)

    $scope.buildSrc = (item) ->
        $scope.trustSrc(sources[item.type].replace('__id__', item.id))

    fetcher.latest (latest) ->
        console.log latest
        $scope.items.list = latest
]
