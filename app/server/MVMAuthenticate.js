(function() {
  "use strict";
  var OAuth2Client, authenticate, googleapis, path, services, url, youtubeConnect;

  googleapis = require('googleapis');

  OAuth2Client = googleapis.OAuth2Client;

  youtubeConnect = require('./youtubeConnect');

  url = require('url');

  path = require("path");

  services = exports.MVMAuthenticate = authenticate = (function() {
    authenticate.prototype._this = null;

    function authenticate() {
      this._this = this;
    }

    authenticate.prototype.init = function(req, res) {
      var service;
      service = req.params.service;
      return res.render("jade/oauth", {
        service: service,
        serviceURL: this[service].init()
      });
    };

    authenticate.prototype.handle = function(req, res) {
      var query, urlParts;
      urlParts = url.parse(req.url, true);
      query = urlParts.query;
      console.log(query);
      return res.render("index");
    };

    authenticate.prototype.google = {
      init: function() {
        var clientId, clientSecret, oauth2Client, redirectUrl;
        clientId = '793238808427.apps.googleusercontent.com';
        clientSecret = 'F37f5_1HLwwLEOrYTafL-hBX';
        redirectUrl = 'https://localhost:9000/oauth2callback';
        oauth2Client = new OAuth2Client(clientId, clientSecret, redirectUrl);
        return url = oauth2Client.generateAuthUrl({
          access_type: 'offline',
          scope: 'https://gdata.youtube.com'
        });
      }
    };

    return authenticate;

  })();

}).call(this);

/*
//@ sourceMappingURL=MVMAuthenticate.js.map
*/