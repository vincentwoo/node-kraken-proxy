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
    res.json JSON.parse(body)

app.listen PORT, ->
  console.log "Listening on #{PORT}"
