(function() {
  "use strict";
  var OAuth2Client, app, coffee, express, google, googleapis, oauth2Client, path, url, youtubeConnect;

  express = require('express');

  googleapis = require('googleapis');

  OAuth2Client = googleapis.OAuth2Client;

  youtubeConnect = require('./server/youtubeConnect');

  coffee = require("coffee-script");

  path = require("path");

  app = express();

  google = {
    clientId: '',
    clientSecret: '',
    redirectUrl: ''
  };

  oauth2Client = new OAuth2Client(google.clientId, google.clientSecret, google.redirectUrl);

  url = oauth2Client.generateAuthUrl({
    access_type: 'offline',
    scope: 'https://www.googleapis.com/auth/plus.me'
  });

  if (process.env.NODE_ENV === "production" || process.argv[2] === "production") {
    console.log("Setting production env variable");
    app.set("env", "production");
    app.locals.dev = false;
  } else {
    app.locals.dev = true;
  }

  app.locals.basedir = '/../';

  app.configure(function() {
    this.set("port", 9000);
    this.set("views", __dirname + "/");
    this.set("view engine", "jade");
    if (app.get("env") === "development") {
      this.use(express.logger("dev"));
    }
    this.use(express.cookieParser("keyboardcat"));
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

  app.get("/youtube", function(req, res, next) {
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

  app.listen(app.locals.settings.port);

  console.log("Express started on port " + app.locals.settings.port);

}).call(this);

/*
//@ sourceMappingURL=server.js.map
*/