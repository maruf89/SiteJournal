"use strict"

angular.module("mvmdApp", [])
  .config( ($routeProvider, $locationProvider) ->
    # $locationProvider.html5Mode true

    $routeProvider
      .when "/",
        templateUrl: "views/main.html"
        controller: "MainCtrl"
      .when '/youtube',
        templateUrl: 'views/youtube.html',
        controller: 'YoutubeCtrl'
  )