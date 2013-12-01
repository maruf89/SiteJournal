myApp = window.myApp

myApp.controller 'NavigationCtrl', ($scope, $element, $attrs) ->
    $scope.pages = []
    console.log arguments
