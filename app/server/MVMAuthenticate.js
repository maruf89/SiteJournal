(function() {
  "use strict";
  var OAuth2Client, authenticate, db, googleapis, path, services, url;

  googleapis = require('googleapis');

  OAuth2Client = googleapis.OAuth2Client;

  db = require('./DB').Database;

  url = require('url');

  path = require('path');

  services = {
    google: {
      clientId: '793238808427.apps.googleusercontent.com',
      clientSecret: 'F37f5_1HLwwLEOrYTafL-hBX',
      redirectUrl: 'https://localhost:9000/oauth2callback',
      oauth2Client: null,
      init: function() {
        services.google.oauth2Client = new OAuth2Client(services.google.clientId, services.google.clientSecret, services.google.redirectUrl);
        return url = services.google.oauth2Client.generateAuthUrl({
          access_type: 'offline',
          scope: 'https://gdata.youtube.com'
        });
      },
      handleToken: function(query, req, res) {
        return services.google.oauth2Client.getToken(query.code, function(err, tokens) {
          if (err) {
            return console.log(err);
          } else {
            console.log('Token Success!');
            console.log(tokens);
            return db.save('api', {
              google: tokens
            }, function(keys) {
              console.log(keys);
              return res.render('jade/authenticated', {
                service: req.session.oauthService
              });
            });
          }
        });
      }
    }
  };

  authenticate = (function() {
    authenticate.prototype._this = null;

    function authenticate() {
      this._this = this;
    }

    authenticate.prototype.init = function(req, res) {
      var service;
      service = req.params.service;
      req.session.oauthService = service;
      return res.render('jade/oauth', {
        service: service,
        serviceURL: services[service].init()
      });
    };

    authenticate.prototype.token = function(req, res) {
      var query;
      query = req.query;
      return services[req.session.oauthService].handleToken(query, req, res);
    };

    return authenticate;

  })();

  exports.MVMAuthenticate = new authenticate();

}).call(this);

/*
//@ sourceMappingURL=MVMAuthenticate.js.map
*/