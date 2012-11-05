// Generated by CoffeeScript 1.3.1
(function() {
  var Config, http, mongoose, redis;

  mongoose = require('mongoose');

  redis = require('redis');

  http = require('http');

  Config = (function() {

    Config.name = 'Config';

    function Config() {
      this.environment = process.env.NODE_ENV || 'development';
      this.initErrors();
      this.initMongo();
      this.initGlobalAgent();
    }

    Config.prototype.initMongo = function() {
      return mongoose.connect(process.env.MONGO_URL || 'mongodb://localhost/casestatus');
    };

    Config.prototype.initErrors = function() {
      var _this = this;
      if (this.environment !== 'development') {
        this.airbrake = require('airbrake').createClient('ec998fc8de1c2584705784a07d381171');
        this.airbrake.serviceHost = 'errbit.plop.pe';
        this.airbrake.timeout = 60 * 1000;
        this.airbrake.handleExceptions();
      }
      return process.reportError = function(err) {
        console.error(err);
        if (_this.airbrake) {
          _this.airbrake.notify(err);
          return console.error('Sent to Errbit');
        }
      };
    };

    Config.prototype.initGlobalAgent = function() {
      return http.globalAgent.maxSockets = Infinity;
    };

    return Config;

  })();

  global.config = new Config;

}).call(this);
