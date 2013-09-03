myApp = angular.module 'mvmdApp', []

myApp.directive 'ngResize', ($window) ->
    (scope) ->
        debugger
        scope.width = $window.innerWidth
        scope.height = $window.innerHeight
        angular.element( $window ).bind 'resize', ->
            scope.$apply ->
                scope.width = $window.innerWidth
                scope.height = $window.innerHeight

myApp.run ($rootScope, $window) ->
	$rootScope.dimensions =
		width: $window.outerWidth
		height: $window.outerHeight

	angular.element( $window ).bind 'resize', ->
		$rootScope.dimensions =
			width: $window.outerWidth
			height: $window.outerHeight

myApp.directive "myDirective", ($document) ->
	restrict: 'A'
	scope:
		myDirective: '@'
		ngResize: '&'
	link: (scope, element, attr) ->
		console.log 'hello world'
		bodyWidth = $document[0].body.clientWidth
		console.log "width of body is " + bodyWidth
