'use strict'

myApp = window.myApp

offset = 0

myApp.controller 'MainCtrl', ['$scope', 'fetcher', ($scope, fetcher) ->
    $scope.items = 
        list: []
        more: true

    fetcherCallback = (latest) ->
        $scope.items.list = $scope.items.list.concat(latest)
        offset = $scope.items.list.length
        $scope.items.more = true

    $scope.loadMore = ->
        fetcher.latest(fetcherCallback, 20, offset)

    $scope.loadMore(fetcherCallback)
]
