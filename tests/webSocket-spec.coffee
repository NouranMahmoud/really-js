#
# Module dependencies.
#

CONFIG              = require './support/server/config.coffee'
protocol            = require '../src/protocol.coffee'
ReallyErorr         = require '../src/really-error.coffee'
WebSocketTransport  = require '../src/transports/webSocket.coffee'
customMatchers      = require './custom-matchers.coffee'
Emitter             = require 'component-emitter'
ws = {}
describe 'webSocket', ->
  beforeEach ->
    jasmine.addMatchers(customMatchers)

  describe 'initialization', ->
    it 'should be initialized with URL', ->
      connection = new WebSocketTransport('wss://a6bcc.api.really.io', 'ibj88w5aye')
      expect(connection.url).toEqual "wss://a6bcc.api.really.io/v#{protocol.clientVersion}/socket"

    it 'should throw error if initialized without passing domain and access token', ->
      expect ->
        connection = new WebSocketTransport()
      .toThrow new ReallyErorr 'Can\'t initialize connection without passing domain and access token'

    it 'should throw error if initialized without passing access token', ->
      expect ->
        connection = new WebSocketTransport('wss://a6bcc.api.really.io', undefined)
      .toThrow new ReallyErorr 'Can\'t initialize connection without passing domain and access token'

    it 'should throw error if initialized without passing domain', ->
      expect ->
        connection = new WebSocketTransport(undefined, 'ibj88w5aye')
      .toThrow new ReallyErorr 'Can\'t initialize connection without passing domain and access token'

    it 'should generate URL with type of string', ->
      expect ->
        connection = new WebSocketTransport(1234, 1234)
      .toThrow new ReallyErorr 'Only <String> values are allowed for domain and access token'

    it 'should accept access token with type of string', ->
      expect ->
        connection = new WebSocketTransport('wss://a6bcc.api.really.io', 1234)
      .toThrow new ReallyErorr 'Only <String> values are allowed for domain and access token'


  describe 'connect', ->

    it 'should use initialize @socket only one time (singleton)', ->
      connection = new WebSocketTransport('wss://a6bcc.api.really.io', 'xxwmn93p0h')
      connection.connect()
      socket1 = connection.socket
      expect(socket1).toBeDefined()
      connection.connect()
      socket2 = connection.socket
      expect(socket2).toBe(socket1)

    xit 'should throw exception when server is blocked/not found', (done)->
      url = 'ws://a6bcc.api.really.com'
      connection = new WebSocketTransport(url, 'xxwmn93p0h')
      expect ->
        connection.connect()
      .toThrow new ReallyErorr "Server with URL: #{url} is not found"
      done()
      
    it 'should send first message', (done) ->
      connection = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'xxwmn93p0h')
      connection.connect()
      message = {cmd: 'init', tag: 1}
      connection.on 'message', (msg) ->
        expect(message).toEqual msg
        done()

    it 'should check if state of connection is initialized after successful connection (onopen)', (done) ->
      ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'xxwmn93p0h')
      ws.connect()
      ws.socket.onopen = ->
        ready_state = ws.socket.readyState
        expect(ready_state).toEqual ws.socket.OPEN
        done()

    it 'should trigger initialized event with user data, after successful connection', (done) ->
      ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'xxwmn93p0h')
      ws.connect()
      ws.on 'message', (msg) ->
        expect(ws.initialized).toBeTruthy()
        done()

    it 'should throw exception if wrong format of initialization, after successful connection', ->

      ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'xxwmn93p0h')
      ws.connect()
      spyOn(ws.callbacksBuffer._callbacks[1], 'error')
      ws.on 'message', (msg) ->
        expect(ws.callbacksBuffer._callbacks[1].error).toHaveBeenCalled()
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
      spyOn(ws.socket, 'send')
      message = {cmd: 'init'}
      ws.send(message, {})
      expect(ws.socket.send).toHaveBeenCalledWith('{cmd: \'init\', tag: 2}')

  describe 'disconnect', ->

    beforeEach ->
      ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5aye')
      ws.connect()

    it 'should close the websocket transport', (done) ->
      ws.socket.onopen = ->
        ws.disconnect()
        ready_state = ws.socket.readyState
        expect(ready_state).toEqual ws.socket.CLOSE
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
