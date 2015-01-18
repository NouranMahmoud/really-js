protocol = require './protocol'
Q = require 'q'
Emitter = require 'component-emitter'
Logger = require './logger'
logger = new Logger()

class Heartbeat
  constructor: (@websocket, @interval = 5e3, @timeout = 5e3) ->
    throw Error('websocket should be passed') unless @websocket
    
    logger.debug "Heartbeat: initialize with interval: #{@interval} and timeout: #{@timeout}"
    

  start: () ->
    _ping.call(this)
    logger.debug "Heartbeat: started interval: #{@interval} timeout: #{@timeout}"

  _ping = () ->
    message = protocol.heartbeatMessage()
    pingPromise = @websocket.send message

    success = (data) =>
      now = Date.now()
      console.log data.timestamp
      lag = (now - data.timestamp) * 0.001
      logger.debug "Heartbeat: lag #{lag} second(s)"
      Q.delay(@interval).then =>
        logger.debug "Heartbeat interval: #{@interval} timeout: #{@timeout}"
        _ping.call(this)
    
    error = (error) =>
      logger.debug 'Heartbeat: lag exceed', error
      @stop()

    pingPromise.timeout(@interval + @timeout).then success, error

  stop: () ->
    @websocket.socket.close()
    @websocket.emit 'heartbeat:lag'
    

module.exports = Heartbeat
