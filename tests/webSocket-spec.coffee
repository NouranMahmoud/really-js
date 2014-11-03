WebSocketTransport = require '../src/transports/webSocket.coffee'
ReallyErorr = require '../src/really-error.coffee'
CONFIG = require './support/server/config.coffee'
protocol = require '../src/protocol.coffee'
WebSocket = require 'ws'

describe 'webSocket', ->
  beforeEach ->
    customMatchers =
      toBeString: ->
        compare: (actual) ->
          result = pass: typeof actual is "string"
          if result.pass
            result.message = actual + " is string type "
          else
            result.message = actual + " is not string type "
          result
    jasmine.addMatchers(customMatchers)

  describe 'initialization', ->
    it 'should be initialized with URL', ->
      connection = new WebSocketTransport("ibj88w5aye")
      expect(connection.url).toEqual "wss://a6bcc.api.really.io/v#{protocol.clientVersion}/socket=ibj88w5aye"

    it 'should throw error if initialized without passing accessToken', ->
      expect ->
        connection = new WebSocketTransport()
      .toThrow new ReallyErorr 'can\'t initialize connection without passing accessToken'

    it 'should generate url with type of string', ->
      connection = new WebSocketTransport("ibj88w5aye")
      expect(connection.url).toBeString()

    it 'should accept accessToken with type of string', ->
      connection = new WebSocketTransport("ibj88w5aye")
      expect(connection.accessToken).toBeString() #Dont forget ()

  describe 'connect', ->
    it 'should use initialize @socket only one time (singleton)', ->
      connection = new WebSocketTransport('wss://a6bcc.api.really.io','ibj88w5aye')
      connection.connect()
      socket_one = connection.socket
      expect(socket_one).toBeDefined()
      connection.connect()
      socket_two = connection.socket
      expect(socket_two).toBe(socket_one)

    it 'should throw exception when server is blocked/not found', ->
      url = 'ws://a6bcc.api.really.com'
      expect ->
        connection = new WebSocketTransport(url, 'ibj88w5aye')
      .toThrow new ReallyErorr "Server with URL: #{url} is not found"

    it 'should send first message', (done) ->
      connection = new WebSocketTransport('wss://a6bcc.api.really.io', 'ibj88w5aye')
      connection.connect()
      spyOn(protocol, 'getInitializationMessage');
      expect(protocol.getInitializationMessage).toHaveBeenCalled();
      connection.on 'message', (msg) ->
        expect(protocol.getInitializationMessage).toEqual msg
        done()

    it 'should check if state of connection is initialized after successful connection (onopen)', (done) ->
      ws = new WebSocket('wss://echo.websocket.org')
      ws.connect()
      console.log ws
      ws.onopen = ->
        ready_state = ws.readyState
        console.log ready_state
        expect(ready_state).toEqual 1
        done()



    it 'should trigger initialized event with user data, after successful connection', ->

    it 'should throw exception if wrong format of initialization, after successful connection', ->

  describe 'send', ->

  describe 'disconnect', ->

  describe 'isConnected', ->
