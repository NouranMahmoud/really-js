#
# Module dependencies.
#

CONFIG              = require './support/server/config.coffee'
protocol            = require '../src/protocol.coffee'
ReallyErorr         = require '../src/really-error.coffee'
WebSocketTransport  = require '../src/transports/webSocket.coffee'
customMatchers      = require './custom-matchers.coffee'

describe 'webSocket', ->
  beforeEach ->
    jasmine.addMatchers(customMatchers)

  describe 'initialization', ->
    it 'should be initialized with URL', ->
      connection = new WebSocketTransport('wss://a6bcc.api.really.io', 'ibj88w5aye')
      expect(connection.url).toEqual "wss://a6bcc.api.really.io/v#{protocol.clientVersion}/socket?access_token=ibj88w5aye"

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

    it 'should generate url with type of string', ->
      expect ->
        connection = new WebSocketTransport(1234, 1234)
      .toThrow new ReallyErorr 'Only <String> values are allowed for domain and access token'

    it 'should accept access token with type of string', ->
      expect ->
        connection = new WebSocketTransport('wss://a6bcc.api.really.io', 1234)
      .toThrow new ReallyErorr 'Only <String> values are allowed for domain and access token'

    it 'should URLS be different if the user make a new connection with new access token', ->
      connection_one = new WebSocketTransport('wss://a6bcc.api.really.io', 'ibj88w5aye')
      connection_two = new WebSocketTransport('wss://a6bcc.api.really.io', 'ibj88w5ayq')
      expect(connection_one.url).not.toEqual connection_two.url

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
      ws = new WebSocketTransport('wss://a6bcc.api.really.io', 'ibj88w5aye')
      ws.connect()
      console.log ws
      ws.onopen = ->
        ready_state = ws.socket.readyState
        console.log ready_state
        expect(ready_state).toEqual 1
        done()

    it 'should trigger initialized event with user data, after successful connection', ->

    it 'should throw exception if wrong format of initialization, after successful connection', ->

  describe 'send', ->

  describe 'disconnect', ->

  describe 'isConnected', ->
