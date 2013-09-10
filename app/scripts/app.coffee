"use strict"

window.$q = ( selector, all = true ) ->
    query = if all then 'querySelector' else 'querySelectorAll'
    document[ query ] selector

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