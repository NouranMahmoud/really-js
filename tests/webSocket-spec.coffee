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

    it 'should construct URL that matches Really URL scheme when domain is passed', ->
      ws = new WebSocketTransport('wss://a6bcc.api.really.io', 'ibj88w5aye')
      expect(ws.url).toEqual "wss://a6bcc.api.really.io/v#{protocol.clientVersion}/socket"

    it 'should throw error if initialized without passing domain and access token or invalid type', ->
      expect ->
        ws = new WebSocketTransport()
      .toThrow new ReallyErorr 'Can\'t initialize connection without passing domain and access token'
      expect ->
        ws = new WebSocketTransport('wss://a6bcc.api.really.io', undefined)
      .toThrow new ReallyErorr 'Can\'t initialize connection without passing domain and access token'
      expect ->
        ws = new WebSocketTransport(undefined, 'ibj88w5aye')
      .toThrow new ReallyErorr 'Can\'t initialize connection without passing domain and access token'
      expect ->
        ws = new WebSocketTransport(1234, 1234)
      .toThrow new ReallyErorr 'Only <String> values are allowed for domain and access token'
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

    it 'should trigger error event when server is blocked/not found', (done)->
      ws = new WebSocketTransport('wss://WRONG_ID.really.io','ibj88w5aye')
      connected = true
      ws.connect()
      ws.on 'error', () ->
        connected = false
      
      setTimeout (->
        expect(connected).toBeFalsy() 
        done()
      ), 1000

    it 'should send first message', (done) ->
      ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5aye')
      ws.connect()
      message = {tag: 1, 'cmd': 'init', accessToken: 'xxwmn93p0h'}
      ws.once 'message', (msg) ->
        expect(message).toEqual msg
        done()

    it 'should check if state of connection is initialized after successful connection (onopen)', (done) ->
      ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5aye')
      ws.connect()
      readyState = ws.socket.readyState
      expect(readyState).toEqual ws.socket.CONNECTING
      ws.socket.onopen = ->
        readyState = ws.socket.readyState
        expect(readyState).toEqual ws.socket.OPEN
        done()

    it 'should trigger initialized event with user data, after calling success callback', (done) ->
      ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5aye')
      ws.connect()
      ws.on 'initialized', (data) ->
       expect(ws.initialized).toBeTruthy()
       done()

    xit 'should trigger error event wrong format of initialization message sent', (done) ->
      # expect(false).toBeTruthy()
      ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5ake')
      initializationErrorEventFired = false
      ws.on 'initializationError', () ->
        initializationErrorEventFired = true

      ws.connect()
      ws.send data: testCmd: 'give-me-error'

      setTimeout (->
        expect(initializationErrorEventFired).toBeTruthy()
        done()
      ), 1500


      # spyOn(ws.callbacksBuffer._callbacks[1], 'error')
      # ws.on 'message', (msg) ->
      #   expect(ws.callbacksBuffer._callbacks[1].error).toHaveBeenCalled()
      #   done()
      

  describe 'send', () ->
    it 'shouldn\'t send messages before initializing', (done) ->
      connection = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5aye')
      setTimeout(-> 
        connection.connect()
        connection.send type: 'default', 'data': 'hello'
        done()
      , 2000)

    
    xit "should raise exception if channel is not connected and connection is not initialized", ->
      expect(false).toBeTruthy()
      # ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5aye')
      # expect ->
      #   ws.send(protocol.createMessage('/users'),{})
      # .toThrow new ReallyErorr 'Connection to the server is not established'

    xit 'should send data with string format with included tag', ->
      expect(false).toBeTruthy()
      # ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5aye')
      # ws.connect();
      # spy = spyOn(ws.socket, 'send')
      # message = {cmd: 'init', accessToken: 'xxwmn93p0h'}
      # ws.send(message, {})
      # expect(spy).toHaveBeenCalledWith('{tag: 2, cmd: \'init\', accessToken: \'xxwmn93p0h \'}')

  xdescribe 'disconnect', ->

    beforeEach ->
      ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5aye')
      ws.connect()

    it 'should close the websocket transport', () ->
      #To be fixed
      expect(false).toBeTruthy()
      # ws.socket.onopen = ->
      #   ws.disconnect()
      #   readyState = ws.socket.readyState
      #   expect(readyState).toEqual ws.socket.CLOSE
      #   done()


    it 'should set the initialized flag to false', () ->
      expect(false).toBeTruthy()
      # ws.socket.onopen = ->
      #   expect(ws.initialized).toBeTruthy()
      #   ws.disconnect()
      #   expect(ws.initialized).toBeFalsy()
      #   done()


    it 'should set the socket instance to null', ->
      expect(false).toBeTruthy()
      # expect(ws.socket).toBeDefined()
      # ws.disconnect()
      # expect(ws.socket).toBeNull()

  xdescribe 'isConnected', ->

    beforeEach ->
      ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5aye')
      ws.connect()

    it 'should return false if socket is not initialized', ->
      expect(false).toBeTruthy()
      # ws.socket = null
      # expect(ws.isConnected()).toBeFalsy()

    it 'should return true if socket is connected/open', ->
      expect(false).toBeTruthy()
      # ws.socket.onopen = ->
      #   expect(ws.isConnected()).toBeTruthy()
