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
      connection = new WebSocketTransport('ibj88w5aye')
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
      expect(connection.accessToken).toBeString()

  describe 'connect', ->
    it "should use initialize @socket only one time (singleton)", ->

    it "should throw exception when server is blocked/not found", ->

    it "should send first message", ->

    it "should check if state of connection is initialized after successful connection", ->

    it "should trigger 'initialized' event with user data, after successful connection", ->

    it "should throw exception if wrong format of initialization, after successful connection", ->

  describe 'send', ->

  describe 'disconnect', ->

  describe 'isConnected', ->
