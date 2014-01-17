'use strict'

myApp = window.myApp

myApp.directive 'soundcloudMusicItem', [ ->
    restrict: 'E'
    scope: 
        item: '='
    controller: 'soundcloudMusic'
    templateUrl: 'views/items/soundcloud-music-item.html'
    link: (scope, el, attr, ctrl) ->
        
]       