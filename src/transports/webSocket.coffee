_ = require 'lodash'
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
    @url = "#{domain}/v#{protocol.clientVersion}/socket"

  # Mixin Emitter
  Emitter(WebSocketTransport.prototype)

  _destroy =  () ->


  _bindWebSocketEvents = ->
    @socket.addEventListener 'open', =>
      @emit 'opened'

    @socket.addEventListener 'close', =>
      @emit 'closed'

    @socket.addEventListener 'message', (e) =>
      {data} = e

      if _.has data, 'tag'
        @callbacksBuffer.handle data
      else
        @pushHandler.handle data

      @emit 'message', JSON.parse data

  connect: (successCallback, errorCallback) ->
    # singleton websocket
    @socket ?= new WebSocket @url
    
    @socket.addEventListener 'error', () =>
      @socket.removeEventListener 'error'
      throw new ReallyError "Server with URL: #{@url} is not found"
      errorCallback()

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
      successCallback()

  disconnect: () ->
    @socket.close()
    @socket = null
    @initialized = false
    _destroy.call(this)

  send: (message, options) ->
    {type} = message
    {success, error} = options
    message.data.tag = @callbacksBuffer.add {type, success, error}
    @socket.send JSON.stringify message.data

  isConnected: () ->
    return false if not @socket
    @socket.readyState is @socket.OPEN

module.exports = WebSocketTransport
