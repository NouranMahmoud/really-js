Transport = require '../transport.coffee'
ReallyError = require '../really-error.coffee'
WebSocket = require 'ws'
protocol = require '../protocol.coffee'
Emitter = require 'component-emitter'
CallbacksBuffer = require '../callbacks-buffer.coffee'
_ = require 'lodash'
PushHandler = require '../push-handler.coffee'

class WebSocketTransport extends Transport

  constructor: (@domain, @accessToken) ->
    unless domain and accessToken
      throw new ReallyError 'Can\'t initialize connection without passing domain and access token' 
    
    unless _.isString(domain) and _.isString(accessToken)
      throw new ReallyError 'Only <String> values are allowed for domain and access token' 
    
    @socket = null
    @callbacksBuffer = new CallbacksBuffer
    @pushHandler = PushHandler

    # connection not initialized yet "we haven't send first message yet"
    @initialized =  false
    @url = "#{domain}/v#{protocol.clientVersion}/socket?access_token=#{accessToken}"
    
  # Mixin Emitter
  Emitter(WebSocketTransport.prototype)
  
  _bindWebSocketEvents = ->
    @socket.addEventListener 'open', =>
      console.log 'OPEN'
      @emit 'opened'
    
    @socket.addEventListener 'close', =>
      console.log 'CLOSED'
      @emit 'closed'
    
    @socket.addEventListener 'message', (e) =>
      {data} = e
      
      if _.has data, 'tag'
        @callbacksBuffer.handle data
      else
        @pushHandler.handle data
      
      @emit 'message', JSON.parse data

  connect: () ->
    # singleton websocket
    try
      @socket ?= new WebSocket @domain
    catch e
      console.error e
      throw new ReallyError "Can't connect to #{@domain}"
    
    _bindWebSocketEvents.call(this)
    
    _sendFirstMessage = =>
      success = (data) =>
        @initialized = true
        @emit 'initialized', data
      
      error = (data) =>
        @initialized = false
        throw new ReallyError "An error happened when initializing connection with server, data returned #{data}"
      
      @send protocol.getInitializationMessage(), {success, error}
    
    @socket.addEventListener 'open', ->
      _sendFirstMessage()

  disconnect: () ->
    @socket.close()
    @socket = null
    @initialized = false

  send: (message, options) ->
    {type} = message
    {success, error} = options
    message.tag = @callbacksBuffer.add {type, success, error}
    @socket.send JSON.stringify message.data

  isConnected: () ->
    return false if not @socket
    @socket.readyState is @socket.OPEN

module.exports = WebSocketTransport
