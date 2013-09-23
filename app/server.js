(function() {
  "use strict";
  var app, coffee, express, fs, http, https, oauth, options, path, serverHTTPS;

  fs = require('fs');

  http = require('http');

  https = require('https');

  express = require('express');

  coffee = require("coffee-script");

  oauth = require('./server/MVMAuthenticate').MVMAuthenticate;

  path = require("path");

  console.log(oauth);

  options = {
    key: fs.readFileSync("" + __dirname + "/../ssl/localhost.key"),
    cert: fs.readFileSync("" + __dirname + "/../ssl/certificate.crt")
  };

  app = express();

  if (process.env.NODE_ENV === "production" || process.argv[2] === "production") {
    console.log("Setting production env variable");
    app.set("env", "production");
    app.locals.dev = false;
  } else {
    app.locals.dev = true;
  }

  app.locals.basedir = '/../';

  app.configure(function() {
    this.set("port", 80);
    this.set("views", __dirname + "/");
    this.set("view engine", "jade");
    if (app.get("env") === "development") {
      this.use(express.logger("dev"));
    }
    this.use(express.cookieParser("keyboardcat"));
    this.use(express.session({
      secret: 'nte234jkTeinuhn234ee2'
    }));
    this.use(express.bodyParser());
    this.use(express.compress());
    this.use(express.methodOverride());
    this.use(app.router);
    this.use(require("connect-asset")({
      assets: path.resolve(__dirname),
      "public": path.resolve("" + app.locals.basedir + ".tmp"),
      buidls: true
    }));
    return this.use(require("stylus").middleware({
      src: "" + this.locals.basedir + ".tmp/styles",
      compress: true
    }));
  });

  app.enable("verbose errors");

  if (app.get("env") === "production") {
    app.disable("verbose errors");
  }

  if (app.get("env") === "development") {
    app.use(express["static"](".tmp"));
    app.use(express["static"]("app"));
  } else {
    app.use(express["static"]("dist"));
  }

  app.use(function(req, res, next) {
    res.status(404);
    if (req.accepts("html")) {
      res.render("404", {
        url: req.url
      });
      return;
    }
    if (req.accepts("json")) {
      res.send({
        error: "Not found"
      });
      return;
    }
    return res.type("txt").send("Not found");
  });

  app.use(function(err, req, res, next) {
    var newErr;
    res.status(err.status || (err.status = 500));
    console.error("Server error catch-all says: ", err);
    if (app.get("env") !== "development") {
      newErr = new Error("Something went wrong. Sorry!");
      newErr.status = err.status;
      err = newErr;
    }
    if (req.accepts("json")) {
      res.send({
        data: err,
        message: err.message
      });
      return;
    }
    if (req.accepts("html")) {
      res.render("errors", {
        data: err,
        message: err.message
      });
      return;
    }
    return res.type("txt").send("Error " + err.status);
  });

  app.get("/", function(req, res, next) {
    return res.render('index');
  });

  app.get("/ssl-gen", function(req, res) {
    csrgen.sslGen();
    return res.render('index');
  });

  app.get("/authenticate/:service", oauth.init);

  app.get("/oauth2callback", oauth.token);

  app.get("/:catchall", function(req, res, next) {
    return res.render('index');
  });

  app.get("/404", function(req, res, next) {
    return next();
  });

  app.get("/403", function(req, res, next) {
    var err;
    err = new Error("not allowed!");
    err.status = 403;
    return next(err);
  });

  app.get("/500", function(req, res, next) {
    return next(new Error("keyboard cat!"));
  });

  serverHTTPS = https.createServer(options, app).listen(app.locals.settings.port, 'mariusmiliunas.com', function() {
    return console.log("HTTPS server started on port " + app.locals.settings.port);
  });

}).call(this);

/*
//@ sourceMappingURL=server.js.map
*/