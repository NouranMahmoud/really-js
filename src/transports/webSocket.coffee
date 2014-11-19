_ = require 'lodash'
Transport = require '../transport.coffee'
ReallyError = require '../really-error.coffee'
WebSocket = require 'ws'
protocol = require '../protocol.coffee'
Emitter = require 'component-emitter'
CallbacksBuffer = require '../callbacks-buffer.coffee'
PushHandler = require '../push-handler.coffee'

class WebSocketTransport extends Transport

  constructor: (@domain, @accessToken) ->
    unless domain and accessToken
      throw new ReallyError 'Can\'t initialize connection without passing domain and access token'

    unless _.isString(domain) and _.isString(accessToken)
      throw new ReallyError 'Only <String> values are allowed for domain and access token'

    @socket = null
    @callbacksBuffer = new CallbacksBuffer
    @_msessagesBuffer = []
    @pushHandler = PushHandler

    # connection not initialized yet "we haven't send first message yet"
    @initialized =  false
    @url = "#{domain}/v#{protocol.clientVersion}/socket"

  # Mixin Emitter
  Emitter(WebSocketTransport.prototype)



  _bindWebSocketEvents = ->
    @socket.addEventListener 'open', =>
      _sendFirstMessage.call(this)
      @emit 'opened'

    @socket.addEventListener 'close', =>
      @emit 'closed'
    
    @socket.addEventListener 'error', =>
      @emit 'error'

    @socket.addEventListener 'message', (e) =>
      data = JSON.parse e.data

      if _.has data, 'tag'
        @callbacksBuffer.handle data
      else
        @pushHandler.handle data

      @emit 'message', data

  _startHearetbeat: () ->
    message = protocol.heartbeatMessage()
    success = (data) =>
      clearTimeout @heartbeatTimeOut
      setTimeout(=> 
        @_startHearetbeat.call(this)
      , 5e3)

    @send message, {success}

    @heartbeatTimeOut = 
    setTimeout( =>
      # we've not received heartbeat response from server yet just die
      clearTimeout @heartbeatTimeOut
      @emit 'heartbeatLag'
      @disconnect()
    , 5e3)
  
  send: (message, options) ->
    unless @isConnected() or @socket.readyState is @socket.CONNECTING
      throw new ReallyError 'Connection to the server is not established'

    # if connection is not initialized and this isn't the initialization message 
    # buffer messages and send them after initialization
    unless @initialized or message.type is 'initialization'
      @_msessagesBuffer.push {message, options}
      return
    # connection is initialized send the message
    {type} = message
    success = options?.success or _.noop
    error = options?.error or _.noop
    message.data.tag = @callbacksBuffer.add {type, success, error}
    @socket.send JSON.stringify message.data
    
  _sendFirstMessage = ->
    success = (data) =>
      @initialized = true
      # send messages in buffer after the connection being initialized
      _.flush.call(this)
      @_startHearetbeat()
      @emit 'initialized', data

    error = (data) =>
      @initialized = false
      @emit 'initializationError', data
    msg = protocol.getInitializationMessage()
    
    @send msg, {success, error}
    
    


  connect: () ->
    # singleton websocket
    @socket ?= new WebSocket @url
    
    @socket.addEventListener 'error', _.once ->
     console.log "error initializing websocket with URL: #{@url}"
    
    _bindWebSocketEvents.call(this)

    return @socket

  _.flush = ->
    setTimeout(=>
      @send(message, options) for {message, options} in @_msessagesBuffer
    , 0)


  isConnected: () ->
    return false if not @socket
    @socket.readyState is @socket.OPEN

  _destroy =  () -> @socket.off()
  
  disconnect: () ->
    @socket.close()
    @socket = null
    @initialized = false
    _destroy.call(this)

module.exports = WebSocketTransport
