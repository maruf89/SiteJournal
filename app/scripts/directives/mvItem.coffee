myApp = window.myApp

myApp.directive 'mvItem', ($window) ->
	restrict: 'A'
	scope: true