(function() {
  var OAuth2Client, authenticate, googleapis, path, youtubeConnect;

  googleapis = require('googleapis');

  OAuth2Client = googleapis.OAuth2Client;

  youtubeConnect = require('./youtubeConnect');

  path = require("path");

  exports.MVMAuthenticate = authenticate = (function() {
    authenticate.prototype._this = null;

    function authenticate() {
      this._this = this;
    }

    authenticate.prototype.init = function(req, res) {
      var service, _this;
      _this = this._this;
      service = req.params.service;
      return res.render('jade/oauth', {
        service: service,
        serviceURL: _this[service].init()
      });
    };

    authenticate.prototype.google = {
      init: function() {
        var oauth2Client, url;
        ({
          clientId: '793238808427.apps.googleusercontent.com',
          clientSecret: 'F37f5_1HLwwLEOrYTafL-hBX',
          redirectUrl: 'https://localhost:9000/oauth2callback'
        });
        oauth2Client = new OAuth2Client(google.clientId, google.clientSecret, google.redirectUrl);
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