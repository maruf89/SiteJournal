module.exports = (app) ->

  # Since this is the last non-error-handling
  # middleware use()d, we assume 404, as nothing else
  # responded.

  # $ curl http://localhost:3000/notfound
  # $ curl http://localhost:3000/notfound -H "Accept: application/json"
  # $ curl http://localhost:3000/notfound -H "Accept: text/plain"
  app.use (req, res, next) ->
    res.status 404

    # respond with html page
    if req.accepts("html")
      res.render "404",
        url: req.url

      return

    # respond with json
    if req.accepts("json")
      res.send error: "Not found"
      return

    # default to plain-text. send()
    res.type("txt").send "Not found"


  # error-handling middleware, take the same form
  # as regular middleware, however they require an
  # arity of 4, aka the signature (err, req, res, next).
  # when connect has an error, it will invoke ONLY error-handling
  # middleware.

  # If we were to next() here any remaining non-error-handling
  # middleware would then be executed, or if we next(err) to
  # continue passing the error, only error-handling middleware
  # would remain being executed, however here
  # we simply respond with an error page.
  app.use (err, req, res, next) ->

    # we may use properties of the error object
    # here and next(err) appropriately, or if
    # we possibly recovered from the error, simply next().
    res.status err.status or (err.status = 500)
    console.error "Server error catch-all says: ", err

    # prevent users from seeing specific error messages in production
    if app.get("env") isnt "development"
      newErr = new Error("Something went wrong. Sorry!")
      newErr.status = err.status
      err = newErr

    # respond with json
    if req.accepts("json")
      res.send
        data: err
        message: err.message

      return
    if req.accepts("html")
      res.render "errors",
        data: err
        message: err.message

      return

    # default to plain-text. send()
    res.type("txt").send "Error " + err.status


