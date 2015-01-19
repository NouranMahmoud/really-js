protocol = require './protocol'
Q = require 'q'
Logger = require './logger'
logger = new Logger()

class Heartbeat
  constructor: (@websocket, @interval = 5e3, @timeout = 5e3) ->
    debugger
    logger.debug "Heartbeat: initialize with interval: #{@interval} and timeout: #{@timeout}"

  start: () ->
    _ping.call(this)
    logger.debug "Heartbeat: started interval: #{@interval} timeout: #{@timeout}"
  
  _ping = () ->
    message = protocol.heartbeatMessage()
    pingPromise = @websocket.send message

    success = (data) =>
      now = Date.now()
      lag = (now - data.timestamp) * 0.001
      logger.debug "Heartbeat: lag #{lag} second(s)"
      Q.delay(@interval).then =>
        logger.debug "Heartbeat interval: #{@interval} timeout: #{@timeout}"
        _ping.call(this)
    
    error = () ->
      logger.debug 'Heartbeat: lag exceed'
      @websocket.socket.close()

    pingPromise.timeout(@interval + @timeout).then success, error

module.exports = Heartbeat
  
