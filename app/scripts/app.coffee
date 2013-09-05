"use strict"

window.myApp = angular.module("mvmdApp", ['ngResource', 'ngSanitize'])


myApp.config( ($routeProvider, $locationProvider) ->
  # $locationProvider.html5Mode true

  $routeProvider
    .when "/",
      templateUrl: "views/main.html"
      controller: "MainCtrl"
    .when '/youtube',
      templateUrl: 'views/youtube.html',
      controller: 'YoutubeCtrl'
)