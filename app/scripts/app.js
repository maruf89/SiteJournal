(function() {
  "use strict";
  window.$q = function(selector, all) {
    var query;
    if (all == null) {
      all = true;
    }
    query = all ? 'querySelector' : 'querySelectorAll';
    return document[query](selector);
  };

  window.myApp = angular.module("mvmdApp", ['ngResource', 'ngSanitize']);

  myApp.config(function($routeProvider, $locationProvider) {
    $locationProvider.html5Mode(true);
    return $routeProvider.when("/", {
      templateUrl: "views/main.html",
      controller: "MainCtrl"
    }).when('/youtube', {
      templateUrl: 'views/youtube.html',
      controller: 'YoutubeCtrl'
    });
  });

}).call(this);

/*
//@ sourceMappingURL=app.js.map
*/