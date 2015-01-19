_ = require 'lodash'
Transport = require '../transport'
ReallyError = require '../really-error'
WebSocket = require 'ws'
protocol = require '../protocol'
Emitter = require 'component-emitter'
CallbacksBuffer = require '../callbacks-buffer'
Q = require 'q'
Heartbeat = require '../heartbeat'
Logger = require '../logger'
logger = new Logger()

# TODO: if connection get closed stop the heartbeat
class WebSocketTransport extends Transport
  constructor: (@domain, @accessToken, @options = {}) ->
    @socket = null
    @callbacksBuffer = new CallbacksBuffer()
    @_messagesBuffer = []
    # connection not initialized yet "we haven't send first message yet"
    @initialized =  false
    @url = "#{domain}/v#{protocol.clientVersion}/socket"

    defaults =
      reconnectionMaxTimeout: 30e3
      heartbeatTimeout: 2e3
      heartbeatInterval: 5e3
      reconnect: true
      onDisconnect: 'buffer'
    @options = _.defaults @options, defaults
    Emitter this

  _closeCallback = () ->
    if @options.reconnect
      @emit 'reconnecting'
      @reconnect()
    else
      @emit 'closed'
      @disconnect()

  _bindWebSocketEvents = (deferred) ->
    @socket.addEventListener 'open', () =>
      @attempts = 0
      deferred.resolve()
      debugger
      _sendFirstMessage.call(this)
      @emit 'opened'
    console.log this
    @socket.addEventListener 'close', _.bind(_closeCallback, this)

    @socket.addEventListener 'error', =>
      @emit 'error'

    @socket.addEventListener 'message', (e) =>
      data = JSON.parse e.data
      @callbacksBuffer.handle data if _.has data, 'tag'
      @emit 'message', data
  
  send: (message, options = {}, deferred = Q.defer()) ->
    console.log @_messagesBuffer
    if @isConnected()
      {kind} = message
     
      success = (data) ->
        options.success? data
        deferred.resolve data
     
      error = (reason) ->
        options.error? reason
        deferred.reject new ReallyError(reason)

      complete = (data) ->
        options.complete? data
      
      message.data.tag = @callbacksBuffer.add {kind, success, error, complete}
      @socket.send JSON.stringify message.data
      
      return deferred.promise
    
    else
      strategy = if _.isFunction @options.onDisconnect then 'custom' else @options.onDisconnect
      _handleDisconnected = (strategy) =>
        fail = () ->
          deferred.reject new ReallyError('Connection to the server is not established')
        
        buffer = () =>
          @_messagesBuffer.push {message, options, deferred}

        custom = () =>
          try
            @options.onDisconnect(this, @_messagesBuffer, ReallyError)
          catch e
            throw new ReallyError('error invoking custom callback')
        
        strategies = {fail, buffer, custom}
        try
          strategies[strategy]()
        catch e
          throw e if e instanceof ReallyError
          throw new ReallyError('Strategy not found')
          
      _handleDisconnected(strategy)

      return deferred.promise

  _sendFirstMessage = ->
    success = (data) =>
      @initialized = true
      # send messages in buffer after the connection being initialized
      _.flush.call(this)
      debugger
      heartbeat = new Heartbeat(this, @options.heartbeatInterval, @options.heartbeatTimeout)
      heartbeat.start()
      @emit 'initialized', data
    
    error = (data) =>
      @initialized = false
      @emit 'initializationError', data
    msg = protocol.initializationMessage(@accessToken)
   
    @send msg, {success, error}

  connect: (deferred = Q.defer()) ->
    @socket = new WebSocket(@url)
    @socket.addEventListener 'error', _.once ->
      console.log "error initializing websocket with URL: #{@url}"
   
    _bindWebSocketEvents.call(this, deferred)
    return deferred.promise
  
  reconnect: () ->
    console.log "I am in reconnect"
    generateTimeout = () =>
      maxInterval = (Math.pow(2, @attempts) - 1) * 1000
      if maxInterval > @options.reconnectionMaxTimeout
        maxInterval = @options.reconnectionMaxTimeout
      
      Math.random() * maxInterval
    @attempts += 1
    #console.log "Times of reconnect"+@attempts
    #console.log "Timeout for every reconnect attemption"+generateTimeout()

    @connect().timeout(generateTimeout()).catch (e) ->
      console.log "---------------------------------------"
      reconnect()
    
  _.flush = ->
    setTimeout(=>
      @send(message, options, deferred) for {message, options, deferred} in @_messagesBuffer
    , 0)

  isConnected: () ->
    return false if not @socket
    @socket.readyState is @socket.OPEN
  
  isConnecting: () ->
    return false if not @socket
    @socket.readyState is @socket.CONNECTING
 
  _destroy =  () -> @off()
 
  disconnect: () ->
    @socket.removeEventListener('close', _closeCallback, false);
    @socket?.close()
    _destroy.call(this)
    debugger
    @socket = null
    @initialized = false

module.exports = WebSocketTransport
