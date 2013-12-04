'use strict'

myApp = window.myApp

prefix = ( property, value ) ->
  obj = {}
  obj[ "-webkit-#{property}" ] = value
  obj[ "-moz-#{property}" ] = value
  obj[ "-ms-#{property}" ] = value
  obj[ property ] = value

  obj

myApp.controller 'YoutubeCtrl', ($scope) ->
    left = bottom = -90
    right = top = Math.abs left
    rotateX = rotateY = 0
    x = y = 0
    $scope.angle = background: 'blue'

    $scope.onMouse = ( e ) ->
      # flip top/bottom
      clientY = Math.abs e.clientY - $scope.height
      clientX = e.clientX

      threshX = $scope.width / 2
      threshY = $scope.height / 2
      domainX = if clientY >= threshY then top else bottom
      domainY = if clientX >= threshX then right else left 

      # map out coords so center of screen is (0,0)
      if domainX is right
        x = clientX - threshX
      else
        x = threshX - clientX

      if domainY is top
        y = clientY - threshY
      else
        y = threshY - clientY

      rotateX = 'rotateY(' + ( x / threshX ) * domainX + 'deg) '
      rotateY = 'rotateX(' + ( y / threshY ) * domainY + 'deg)'

      $scope.angle = prefix 'transform', rotateX + rotateY


