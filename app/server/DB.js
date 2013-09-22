(function() {
  var BSON, Connection, DB, Db, ObjectID, Server, server_config;

  Db = require('mongodb').Db;

  Connection = require('mongodb').Connection;

  Server = require('mongodb').Server;

  BSON = require('mongodb').BSON;

  ObjectID = require('mongodb').ObjectID;

  server_config = new Server('localhost', 27017, {
    auto_reconnect: true,
    native_parser: true
  });

  DB = (function() {
    function DB() {
      this.db = new Db('MVMDesign', server_config, {
        safe: false
      });
      this.db.open(function() {});
    }

    DB.prototype.save = function(collection, keys, callback) {
      if (!callback) {
        console.log('Callback Required.');
        return false;
      }
      return this.db.collection(collection, function(err, keysColl) {
        if (err) {
          return callback(err);
        } else {
          if (keys.length == null) {
            keys = [keys];
          }
          return keysColl.insert(keys, function() {
            console.log("Successfully inserted into " + collection);
            return callback(null, keys);
          });
        }
      });
    };

    return DB;

  })();

  exports.Database = new DB();

}).call(this);

/*
//@ sourceMappingURL=DB.js.map
*/