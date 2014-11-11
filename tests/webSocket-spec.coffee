#
# Module dependencies.
#

CONFIG              = require './support/server/config.coffee'
protocol            = require '../src/protocol.coffee'
ReallyErorr         = require '../src/really-error.coffee'
WebSocketTransport  = require '../src/transports/webSocket.coffee'
ws = {}

describe 'webSocket', ->

  describe 'initialization', ->

    it 'should be initialized with URL', ->
      ws = new WebSocketTransport('wss://a6bcc.api.really.io', 'ibj88w5aye')
      expect(ws.url).toEqual "wss://a6bcc.api.really.io/v#{protocol.clientVersion}/socket"

    it 'should throw error if initialized without passing domain and access token', ->
      expect ->
        ws = new WebSocketTransport()
      .toThrow new ReallyErorr 'Can\'t initialize connection without passing domain and access token'

    it 'should throw error if initialized without passing access token', ->
      expect ->
        ws = new WebSocketTransport('wss://a6bcc.api.really.io', undefined)
      .toThrow new ReallyErorr 'Can\'t initialize connection without passing domain and access token'

    it 'should throw error if initialized without passing domain', ->
      expect ->
        ws = new WebSocketTransport(undefined, 'ibj88w5aye')
      .toThrow new ReallyErorr 'Can\'t initialize connection without passing domain and access token'

    it 'should generate URL with type of string', ->
      expect ->
        ws = new WebSocketTransport(1234, 1234)
      .toThrow new ReallyErorr 'Only <String> values are allowed for domain and access token'

    it 'should accept access token with type of string', ->
      expect ->
        ws = new WebSocketTransport('wss://a6bcc.api.really.io', 1234)
      .toThrow new ReallyErorr 'Only <String> values are allowed for domain and access token'

  describe 'connect', ->

    it 'should initialize @socket only one time (singleton)', ->
      ws = new WebSocketTransport('wss://a6bcc.api.really.io','ibj88w5aye')
      ws.connect()
      socket1 = ws.socket
      expect(socket1).toBeDefined()
      ws.connect()
      socket2 = ws.socket
      expect(socket2).toBe(socket1)

    it 'should throw exception when server is blocked/not found', ->
      url = 'ws://a6bcc.api.really.com'
      ws = new WebSocketTransport(url, 'ibj88w5aye')
      expect ->
        ws.connect()
      .toThrow new ReallyErorr "Server with URL: #{url} is not found"

    it 'should send first message', (done) ->
      ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5aye')
      ws.connect()
      message = {tag: 1, 'cmd': 'init', accessToken: 'Ac66bf'}
      ws.on 'message', (msg) ->
        expect(message).toEqual msg
        done()

    it 'should check if state of connection is initialized after successful connection (onopen)', (done) ->
      ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5aye')
      ws.connect()
      ws.socket.onopen = ->
        readyState = ws.socket.readyState
        expect(readyState).toEqual ws.socket.OPEN
        done()

    it 'should trigger initialized event with user data, after calling success callback', (done) ->
      ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5aye')
      ws.connect()
      x = ->
          expect(ws.initialized).toBeTruthy()

      ws.on 'message', (msg) ->
        setTimeout x, 50000
        done()

    it 'should throw exception, after calling error callback if wrong format of initialization message', ->
      ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5ake')
      ws.connect()
      spy = spyOn(ws.callbacksBuffer._callbacks[1], 'error')
      ws.on 'message', (msg) ->
        expect(spy).toHaveBeenCalled()
        done()

  describe 'send', ->
    it "should raise exception if channel is not connected and connection is not initialized", ->
      ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5aye')
      expect ->
        ws.send(protocol.createMessage('/users'),{})
      .toThrow new ReallyErorr "Connection with server is not established."

    it 'should send data with string format with included tag', ->
      ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5aye')
      ws.connect();
      spy = spyOn(ws.socket, 'send')
      message = {cmd: 'init', accessToken: 'Ac66bf'}
      ws.send(message, {})
      expect(spy).toHaveBeenCalledWith('{tag: 2, cmd: \'init\', accessToken: \'Ac66bf \'}')

  describe 'disconnect', ->

    beforeEach ->
      ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5aye')
      ws.connect()

    it 'should close the websocket transport', (done) ->
      #To be fixed
      ws.socket.onopen = ->
        ws.disconnect()
        readyState = ws.socket.readyState
        expect(readyState).toEqual ws.socket.CLOSE
        done()


    it 'should set the initialized flag to false', (done) ->
      ws.socket.onopen = ->
        expect(ws.initialized).toBeTruthy()
        ws.disconnect()
        expect(ws.initialized).toBeFalsy()
        done()


    it 'should set the socket instance to null', ->
      expect(ws.socket).toBeDefined()
      ws.disconnect()
      expect(ws.socket).toBeNull()

  describe 'isConnected', ->

    beforeEach ->
      ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5aye')
      ws.connect()

    it 'should return false if socket is not initialized', ->
      ws.socket = null
      expect(ws.isConnected()).toBeFalsy()

    it 'should return true if socket is connected/open', ->
      ws.socket.onopen = ->
        expect(ws.isConnected()).toBeTruthy()
