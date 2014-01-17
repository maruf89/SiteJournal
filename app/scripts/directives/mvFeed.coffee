'use strict'

myApp = window.myApp

myApp.directive 'mvFeed', [ ->
    restrict: 'E'
    scope: true
    templateUrl: 'views/feed.html'
    controller: 'MainCtrl'
]       