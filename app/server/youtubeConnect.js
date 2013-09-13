(function() {
  var BSON, Connection, Db, ObjectID, Server, youtubeConnect;

  Db = require('mongodb').Db;

  Connection = require('mongodb').Connection;

  Server = require('mongodb').Server;

  BSON = require('mongodb').BSON;

  ObjectID = require('mongodb').ObjectID;

  youtubeConnect = (function() {
    function youtubeConnect() {
      this.db = new Db('node-mongo-blog', new Server(host, port, {
        auto_reconnect: true
      }, {}));
      this.db.open(function() {});
    }

    youtubeConnect.prototype.save = function(keys, callback) {
      return this.db.collection('api', function(err, keysColl) {
        if (err) {
          return callback(err);
        } else {
          if (keys.length == null) {
            keys = [keys];
          }
          return keysColl.insert(keys, function() {
            return callback(null, keys);
          });
        }
      });
    };

    return youtubeConnect;

  })();

  exports.youtubeConnect = youtubeConnect;

}).call(this);

/*
//@ sourceMappingURL=youtubeConnect.js.map
*/