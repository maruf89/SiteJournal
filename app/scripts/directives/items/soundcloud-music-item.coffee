'use strict'

myApp = window.myApp

myApp.directive 'soundcloudMusicItem', [ ->
    restrict: 'E'
    scope: 
        item: '='
    controller: 'soundcloudMusic'
    templateUrl: 'views/items/soundcloud-music-item.html'
    link: (scope, el, attr, ctrl) ->
        background = el[0].querySelector('.background-color')
        
        document.addEventListener "scWhile#{scope.$id}", (e) ->
            current = e.detail.current * 100
            background.style.width = "#{current}%"
]       