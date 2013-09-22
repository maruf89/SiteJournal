(function() {
  "use strict";
  var OAuth2Client, authenticate, config, db, googleapis, path, request, service, serviceList, services, url, visible;

  googleapis = require('googleapis');

  OAuth2Client = googleapis.OAuth2Client;

  request = require('request');

  db = require('./DB').Database;

  url = require('url');

  path = require('path');

  config = {
    domain: null
  };

  serviceList = [];

  services = {
    _8tracks: {
      visible: {
        name: '8tracks',
        api: null
      },
      apiKey: '63eb25d5180ed975def1f62af625d1573e8826e6',
      init: function() {
        var curl;
        return curl = "curl --header 'X-Api-Key: " + services._8tracks.apiKey + "' http://8tracks.com/mixes.xml";
      }
    },
    google: {
      visible: {
        name: 'Google',
        api: null
      },
      clientId: '793238808427.apps.googleusercontent.com',
      clientSecret: 'F37f5_1HLwwLEOrYTafL-hBX',
      redirectUrl: "" + config.domain + "oauth2callback",
      oauth2Client: null,
      init: function(req, res, next) {
        this.oauth2Client = new OAuth2Client(this.clientId, this.clientSecret, this.redirectUrl);
        url = this.oauth2Client.generateAuthUrl({
          access_type: 'offline',
          scope: 'https://gdata.youtube.com'
        });
        return res.render('jade/oauth/oauth', {
          service: 'Google',
          serviceURL: url
        });
      },
      handleToken: function(req, res, next) {
        var query;
        query = req.query;
        return this.oauth2Client.getToken(query.code, function(err, tokens) {
          if (err) {
            return console.log(err);
          } else {
            console.log('Google Auth Success!');
            return db.save('api', {
              google: tokens
            }, function(keys) {
              console.log(keys);
              return res.render('jade/oauth/authenticated', {
                service: req.session.oauthService
              });
            });
          }
        });
      }
    },
    twitter: {
      visible: {
        name: 'Twitter',
        api: null
      },
      consumerKey: 'NqgUDV2ETwpVlRHx0sqwnA',
      consumerSecret: 'uyDs2s4tf6JzjdEcrge0ANKxL4KPWtU2LeRcBunT60',
      accessToken: '198591770-yCHAkPiiSHameV53NVmYHZBMt92hIxo4usm1s30p',
      accessTokenSecret: 'CXi98cEwgXb9fZj06BeiWjJne6vDMwkUf4oRgAI25f0',
      twitterAuth: null,
      init: function() {
        this.twitterAuth = require('twitter-oauth')({
          consumerKey: this.consumerKey,
          consumerSecret: this.consumerSecret,
          domain: config.domain,
          loginCallback: "oauth2callback",
          oauthCallbackCallback: this.success
        });
        return this.twitterAuth.oauthConnect.apply(this, arguments);
      },
      handleToken: function() {
        return this.twitterAuth.oauthCallback.apply(this, arguments);
      },
      success: function(req, res, next, name, accessToken, accessTokenSecret) {
        var tokens;
        console.log('Twitter Auth Success!');
        tokens = {
          name: name,
          accessToken: accessToken,
          accessTokenSecret: accessTokenSecret
        };
        return db.save('api', {
          twitter: tokens
        }, function(keys) {
          console.log(keys);
          return res.render('jade/oauth/authenticated', {
            service: req.session.oauthService
          });
        });
      }
    }
  };

  for (service in services) {
    visible = services[service].visible;
    visible.api = service;
    serviceList.push(visible);
  }

  console.log(serviceList);

  authenticate = (function() {
    authenticate.prototype._this = null;

    function authenticate(domain) {
      this._this = this;
      config.domain = domain;
    }

    authenticate.prototype.init = function(req, res, next) {
      return res.render('jade/oauth/authenticate', {
        services: serviceList
      });
    };

    authenticate.prototype.service = function(req, res, next) {
      var name;
      name = req.params.service;
      req.session.oauthService = name;
      service = services[name];
      console.log("" + name + " service requested");
      return service.init.apply(service, arguments);
    };

    authenticate.prototype.token = function(req, res, next) {
      console.log(req.session.oauthService + ' token returned');
      service = services[req.session.oauthService];
      return service.handleToken.apply(service, arguments);
    };

    authenticate.prototype.success = function(req, res) {
      return res.render('jade/oauth/authenticated', {
        service: req.session.oauthService
      });
    };

    return authenticate;

  })();

  exports.MVMAuthenticate = authenticate;

}).call(this);

/*
//@ sourceMappingURL=MVMAuthenticate.js.map
*/