"use strict"

window.$q = (selector, all = true) ->
    query = if all then 'querySelector' else 'querySelectorAll'
    document[query] selector

window.myApp = angular.module('mvmdApp', ['ngRoute', 'ngResource', 'ngSanitize', 'btford.socket-io'])

myApp.config ['$routeProvider', '$locationProvider', '$sceDelegateProvider', ($routeProvider, $locationProvider, $sce) ->
    $locationProvider.html5Mode(true)

    $sce.resourceUrlWhitelist([
        # whitelist self
        'self'

        # youtube
        'http*://s.ytimg.com/**'
        'http*://s.youtube.com/**'
    ])

    $routeProvider
        .when '/',
            templateUrl: 'views/main.html'
            # controller: 'MainCtrl'
        .when '/youtube',
            templateUrl: 'views/youtube.html',
            controller: 'YoutubeCtrl'
]