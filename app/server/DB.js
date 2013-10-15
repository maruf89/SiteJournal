(function() {
  var DB, redis, _;

  redis = require('redis');

  _ = require('underscore');

  DB = (function() {
    function DB() {
      this.client = redis.createClient();
    }

    DB.prototype.hsave = function(database, key, values, callback) {
      var that;
      that = this;
      if (!callback) {
        console.log('Callback Required.');
        return false;
      }
      database = "hash " + database + ":" + key;
      _.each(values, function(value, key) {
        return that.client.hset(database, value, key, redis.print);
      });
      return console.log("saved to " + database);
    };

    return DB;

  })();

  exports.Database = new DB();

}).call(this);

/*
//@ sourceMappingURL=DB.js.map
*/