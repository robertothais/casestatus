mongoose = require 'mongoose'
redis    = require 'redis'
http    = require 'http'

class Config

  constructor: -> 
    @environment = process.env.NODE_ENV || 'development'
    this.initErrors()
    this.initMongo()
    this.initGlobalAgent()

  initMongo: ->
    mongoose.connect process.env.MONGO_URL || 'mongodb://localhost/casestatus'

  initErrors: ->
    unless @environment is 'development'
      @airbrake = require('airbrake').createClient 'ec998fc8de1c2584705784a07d381171'
      @airbrake.serviceHost = 'errbit.plop.pe'
      @airbrake.timeout = 60 * 1000
      @airbrake.handleExceptions()
    process.reportError = (err) =>
      console.error err
      if @airbrake
        @airbrake.notify err
        console.error 'Sent to Errbit'

  initGlobalAgent: ->
    http.globalAgent.maxSockets = Infinity

global.config = new Config