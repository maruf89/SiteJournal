'use strict'

myApp = window.myApp

offset = 0

myApp.controller 'MainCtrl', ['$scope', 'fetcher', '$compile', ($scope, fetcher, $compile) ->
    $scope.$root.activeScope = $scope
    angular.$compile = $compile

    $scope.items = 
        list: []
        more: true

    fetcherCallback = (latest, callback) ->
        $scope.items.list = $scope.items.list.concat(latest)
        offset = $scope.items.list.length
        $scope.items.more = true
        callback(latest) if callback

        React.renderComponent feedRepeat(scope: $scope, compile: $compile), document.getElementById('feedRepeat')

    $scope.loadMore = (callback) ->
        if callback then callback = _.partialRight(fetcherCallback, callback);
        else callback = fetcherCallback

        fetcher.latest(callback, 20, offset)

    $scope.loadMore()
]
