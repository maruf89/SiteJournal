(function() {
  "use strict";
  var app, express, port;

  express = require("express");

  app = express();

  port = 9000;

  if (process.env.NODE_ENV === "production" || process.argv[2] === "production") {
    console.log("Setting production env variable");
    app.set("env", "production");
    app.locals.dev = false;
  } else {
    app.locals.dev = true;
  }

  app.set("views", __dirname + "/views");

  app.set("view engine", "jade");

  if (app.get("env") === "development") {
    app.use(express.logger("dev"));
  }

  app.use(express.cookieParser("keyboardcat"));

  app.use(express.bodyParser());

  app.use(express.compress());

  app.use(express.methodOverride());

  app.enable("verbose errors");

  if (app.get("env") === "production") {
    app.disable("verbose errors");
  }

  app.use(app.router);

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
    return res.send("hello Bob!");
  });

  app.get("/normal", function(req, res, next) {
    return res.render("normal");
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

  app.listen(port);

  console.log("Express started on port " + port);

}).call(this);

/*
//@ sourceMappingURL=server.js.map
*/