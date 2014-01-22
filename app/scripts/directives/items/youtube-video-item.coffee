'use strict'

myApp = window.myApp

myApp.directive 'youtubeVideoItem', [ ->
    restrict: 'E'
    scope: 
        item: '='
    controller: 'youtubeVideo'
    templateUrl: 'views/items/youtube-video-item.html'
    link: (scope, el, attr, ctrl) ->
        
]