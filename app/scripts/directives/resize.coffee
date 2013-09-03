myApp = angular.module 'mvmdApp', []

myApp.directive 'ngResize', ($window) ->
    ($scope) ->
        debugger
        $scope.width = $window.innerWidth
        $scope.height = $window.innerHeight
        angular.element( $window ).bind 'resize', ->
            $scope.$apply ->
                $scope.width = $window.innerWidth
                $scope.height = $window.innerHeight