'use strict'

angular.module('mvmdApp')
  .controller 'YoutubeCtrl', ($scope, $rootScope) ->
    side = angular.element( '.sides' )

    left = bottom = -90
    right = top = Math.abs left
    rotateX = rotateY = 0
    x = y = 0

    $rootScope.$watch 'dimensions', ( newVal, oldVal ) ->

    $scope.onMouse = ( e ) ->
      # flip top/bottom
      clientY = Math.abs e.clientY - $scope.height
      clientX = e.clientX

      threshX = $scope.width / 2
      threshY = $scope.height / 2
      domainX = if clientX >= threshX then right else left
      domainY = if clientY >= threshY then top else bottom 

      # map out coords so center of screen is (0,0)
      if domainX is left
        x = clientX - threshX
      else
        x = threshX - clientX

      if domainY is bottom
        y = clientY - threshY
      else
        y = threshY - clientY

      rotateX = 'rotateX(' + ( x / threshX ) * domainX + 'deg) '
      rotateY = 'rotateY(' + ( y / threshY ) * domainY + 'deg)'

      side.css 'transform', rotateX + rotateY


