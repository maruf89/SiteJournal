(function() {
  "use strict";
  var OAuth2Client, authenticate, db, googleapis, path, services, url;

  googleapis = require('googleapis');

  OAuth2Client = googleapis.OAuth2Client;

  db = require('./DBSave');

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
      handleToken: function(query) {
        return services.google.oauth2Client.getToken(query.code, function(err, tokens) {
          if (err) {
            return console.log(err);
          } else {
            console.log('Token Success!');
            return console.log(tokens);
          }
        });
      }
    }
  };

  exports.MVMAuthenticate = authenticate = (function() {
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
      return services[req.session.oauthService].handleToken(query);
    };

    return authenticate;

  })();

}).call(this);

/*
//@ sourceMappingURL=MVMAuthenticate.js.map
*/