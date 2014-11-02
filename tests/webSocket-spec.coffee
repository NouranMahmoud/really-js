WebSocketTransport = require '../src/transports/webSocket.coffee'
ReallyErorr = require '../src/really-error.coffee'
CONFIG = require './support/server/config.coffee'
protocol = require '../src/protocol.coffee'

describe 'webSocket', ->
  
  describe 'initialization', ->
  
    it 'should be initialized with domain', ->
      connection = new WebSocketTransport("#{CONFIG.REALLY_DOMAIN}", 'ibj88w5aye')
      expect(connection.url).toEqual("#{CONFIG.REALLY_DOMAIN}/v0/socket?access_token=ibj88w5aye")
      

    it 'should throw error if initialized without passing domain and/or access token', ->
      expect ->
        connection = new WebSocketTransport()
      .toThrow new ReallyErorr 'Can\'t initialize connection without passing domain and access token'
      expect ->
        connection = new WebSocketTransport('ws://localhost:1447')
      .toThrow new ReallyErorr 'Can\'t initialize connection without passing domain and access token'
     
  describe 'connect', ->
    it 'should send the first initialization message', (done) ->
      websocket = new WebSocketTransport CONFIG.REALLY_DOMAIN, 'ibj88w5aye'

      websocket.connect()
      
      websocket.on 'message', (data) ->
        expect(data).toEqual {cmd: 'init'}
        console.log websocket
        done()
      
    
 
  ddescribe 'close', ->
    iit 'should destroy previous instance of websocket', (done)->
      websocket = new WebSocketTransport CONFIG.REALLY_DOMAIN, 'ibj88w5aye'

      websocket.connect()
      
      # close after receiving first message
      websocket.on 'message', () ->
        websocket.disconnect()
      
      websocket.on 'closed', (data) ->
        console.log 'TEST IS RUNING'
        expect(websocket.socket).toBeNull()
        done()
    

