require '../lib/config'
express     = require 'express'

app = express.createServer()

app.listen process.env.PORT

app.configure ->
  this.use express.logger('dev')  
  this.use express.responseTime()  
  this.use express.static("#{__dirname}/../public", maxAge: 31557600000)
  this.use require('connect-assets')
    detectChanges: false
  this.use express.cookieParser()
  this.set 'view options', layout: false
  this.set 'view engine', 'jade'
  this.enable 'view cache'
  this.use express.errorHandler
    dumpExceptions: true
    showStack: (process.env.NODE_ENV == 'development')

app.get "/", (req, res) ->
  res.render 'index'