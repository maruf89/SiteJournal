myApp = window.myApp

pageLinks = [
    'youtube'
    'plus'
]

myApp.directive 'navigation', [ () ->
    restrict: 'E'
    templateUrl: 'views/navigation.html'
    scope: true
    #controller: 'NavigationCtrl'
    link: (scope, element, attrs) ->
        scope.pages = {}
        scope.pages.links = pageLinks
]