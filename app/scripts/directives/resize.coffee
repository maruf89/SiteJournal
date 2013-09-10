myApp = window.myApp

myApp.directive 'resize', ($window) ->
    (scope) ->
        scope.width = $window.innerWidth
        scope.height = $window.innerHeight

        $window.onresize = ->
            scope.$apply ->
                scope.width = $window.innerWidth
                scope.height = $window.innerHeight
            console.log scope.width
            