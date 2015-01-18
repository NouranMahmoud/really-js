Heartbeat = require('../src/heartbeat')
protocol = require '../src/protocol'
Q = require 'q'

describe 'Heartbeat', ->
  websocket =
    send: (message) ->
      deferred = Q.defer()
      return deferred.promise

  describe 'initialization', ->
    it 'should set default interval time and timeout when no parameter passed', ->
      heartbeat = new Heartbeat(websocket)
      expect(heartbeat.interval).toEqual 5e3
      expect(heartbeat.timeout).toEqual 5e3

    it 'should take websocket as a parameter', ->
      expect ->
        heartbeat = new Heartbeat()
      .toThrow Error('websocket should be passed')

  describe 'start', ->
    it 'should create heartbeat message', ->
      heartbeat = new Heartbeat(websocket)
      spyOn(protocol, 'heartbeatMessage').and.callFake ->
        message =
          heartbeat: true

      heartbeat.start(websocket)
      expect(protocol.heartbeatMessage).toHaveBeenCalled()

    it 'should send heartbeat message', ->
      heartbeat = new Heartbeat(websocket)
      spyOn(heartbeat.websocket, 'send').and.callFake ->
        deferred = Q.defer()
        return deferred.promise

      heartbeat.start()
      expect(heartbeat.websocket.send).toHaveBeenCalledWith jasmine.any(Object)

    
    it 'should raise promise success when resolved', (done) ->
      heartbeat = new Heartbeat(websocket,1000,1000)
      spyOn(heartbeat.websocket, 'send').and.callFake () ->
        deferred = Q.defer()
        deferred.resolve
          timestamp: 123
        return deferred.promise

      heartbeat.start()
      setTimeout( () ->
        expect(heartbeat.websocket.send.calls.count()).toEqual 2
        done()
      , 1500)
       
    it 'should raise promise error when timeout', (done) ->
      heartbeat = new Heartbeat(websocket, 1000, 1000)
      spyOn(heartbeat, 'stop').and.callThrough()
      heartbeat.start()

      setTimeout( () ->
        expect(heartbeat.stop).toHaveBeenCalled()
        done()
      , 2500)

    it 'should raise promise error when rejected', (done) ->
      websocket =
        send: (message) ->
          deferred = Q.defer()
          deferred.reject 'ERROR'
          return deferred.promise

      heartbeat = new Heartbeat(websocket, 1000, 1000)

      spyOn(heartbeat, 'stop')

      heartbeat.start()
      setTimeout( () ->
        expect(heartbeat.stop).toHaveBeenCalled()
        done()
      , 0)

  describe 'stop', ->
    it 'should close websocket', (done) ->
      websocket =
        send: (message) ->
          deferred = Q.defer()
          deferred.reject 'ERROR'
          return deferred.promise
        socket:
          close: () -> true
      
      heartbeat = new Heartbeat(websocket, 1000, 1000)
      spyOn(heartbeat.websocket.socket, 'close')
      heartbeat.start()
      setTimeout( () ->
        expect(heartbeat.websocket.socket.close).toHaveBeenCalled()
        done()
      , 0)

    it 'should fire event on websocket', (done) ->
      websocket =
        emit: (msg) -> true
        send: (message) ->
          deferred = Q.defer()
          deferred.reject 'ERROR'
          return deferred.promise
        socket:
          close: () -> true

      
      heartbeat = new Heartbeat(websocket, 1000, 1000)
      spyOn(heartbeat.websocket, 'emit')
      heartbeat.start()
      setTimeout( () ->
        expect(heartbeat.websocket.emit).toHaveBeenCalled()
        done()
      , 0)