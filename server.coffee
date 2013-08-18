# deps
app     = require('express')()
request = require 'request'

# config
PORT    = process.env.PORT   || 5000
ORIGIN  = process.env.ORIGIN || 'http://everlane.s3.amazonaws.com'
KRAKEN_AUTH = {
  api_key:    process.env.KRAKEN_API_KEY
  api_secret: process.env.KRAKEN_API_SECRET
}
hasHeader = request.Request.prototype.hasHeader

app.use (req, res) ->
  path   = req.path
  params = req.query

  request.post {
    uri: 'https://api.kraken.io/v1/url'
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    }
    body: JSON.stringify {
      auth: KRAKEN_AUTH
      url: ORIGIN + path
      wait: true
    }
  }, (error, response, body) ->
    kraken_info = JSON.parse(body)
    console.log kraken_info
    if kraken_info.success
      request.get {
        uri: kraken_info.kraked_url
        encoding: 'binary'
      }, (error, response, body) ->
        if (header = hasHeader('content-type', response.headers))
          res.setHeader 'Content-Type', response.headers[header]
        res.setHeader 'Content-Length', kraken_info.kraked_size
        res.setHeader 'Cache-Control', 'public, max-age=31536000'
        res.end body, 'binary'
    else
      res.json kraken_info

app.listen PORT, ->
  console.log "Listening on #{PORT}"
