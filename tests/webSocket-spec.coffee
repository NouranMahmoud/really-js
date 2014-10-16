WebSocketTransport = require '../src/transports/webSocket.coffee'
ReallyErorr = require '../src/really-error.coffee'
CONFIG = require './support/server/config.coffee'
protocol = require '../src/protocol.coffee'

describe 'webSocket', ->
  
  describe 'initialization', ->
  
    it 'should be initialized with URL', ->
      connection = new WebSocketTransport("localhost:#{CONFIG.WEBSOCKET_SERVER_PORT}")
      expect(connection.url).toEqual("ws://localhost:#{CONFIG.WEBSOCKET_SERVER_PORT}/v0/websocket")

    it 'should throw error if initialized without passing url', ->
      expect ->
        connection = new WebSocketTransport()
      .toThrow new ReallyErorr 'can\'t initialize connection without passing URL'
  
  describe 'connect', ->
    it 'should send the first initialization message', (done)->
      
      websocket = new WebSocketTransport "localhost:#{CONFIG.WEBSOCKET_SERVER_PORT}"

      websocket.connect('ibj88w5aye')
      
      websocket.on 'message', (data) ->
        expect(data).toEqual protocol.getInitializationMessage('ibj88w5aye')
        done()
    

