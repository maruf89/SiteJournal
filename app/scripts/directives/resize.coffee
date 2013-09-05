myApp = window.myApp

myApp.directive 'resize', ($window) ->
    (scope) ->
        scope.width = $window.innerWidth
        scope.height = $window.innerHeight
        angular.element( $window ).bind 'resize', ->
            scope.$apply ->
                scope.width = $window.innerWidth
                scope.height = $window.innerHeight