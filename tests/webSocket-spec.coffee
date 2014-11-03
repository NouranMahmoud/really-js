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
      connection = new WebSocketTransport('wss://a6bcc.api.really.io', 'ibj88w5aye')
      expect(connection.url).toBeString()

    it 'should accept access token with type of string', ->
      connection = new WebSocketTransport('wss://a6bcc.api.really.io', 'ibj88w5aye')
      expect(connection.accessToken).toBeString()

    it 'should URLS be different if the user make a new connection with new access token', ->
      connection_one = new WebSocketTransport('wss://a6bcc.api.really.io', 'ibj88w5aye')
      connection_two = new WebSocketTransport('wss://a6bcc.api.really.io', 'ibj88w5ayq')
      expect(connection_one.url).not.toEqual connection_two.url

  xdescribe 'connect', ->
    it 'should send the first initialization message', (done)->
      
      websocket = new WebSocketTransport "localhost:#{CONFIG.WEBSOCKET_SERVER_PORT}"

    it 'should send first messag', ->

    it 'should check if state of connection is initialized after successful connection', ->

    it 'should trigger initialized event with user data, after successful connection', ->

