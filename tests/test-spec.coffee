#
# Module dependencies.
#

CONFIG              = require './support/server/config'
protocol            = require '../src/protocol'
ReallyError         = require '../src/really-error'
WebSocketTransport  = require '../src/transports/webSocket'
CallbacksBuffer     = require '../src/callbacks-buffer'
PushHandler         = require '../src/push-handler'

options =
  reconnectionMaxTimeout: 30e3
  heartbeatTimeout: 3e3
  heartbeatInterval: 5e3
  reconnect: true
  onDisconnect: 'buffer'

describe 'webSocket', ->
  ws = {}

  afterEach: ->
    ws.disconnect()

  iit 'disconnect should remove the instance from store ', ->
    ws1 = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5aye', options)
    ws1.connect()
    ws1.disconnect()

    ws2 = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5aye', options)
    ws2.connect()

    expect(ws1).not.toBe ws2

  it 'should send first message', (done) ->
    ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5aye', options)
    ws.connect()
    message = {tag: 1, 'cmd': 'init', accessToken: 'ibj88w5aye'}
    ws.on 'message', (msg) ->
      expect(message).toEqual msg
      done()

  it 'should trigger initialized event with user data, after calling success callback', (done) ->
    ws = new WebSocketTransport(CONFIG.REALLY_DOMAIN, 'ibj88w5aye', options)
    ws.connect()
    ws.on 'initialized', (data) ->
      expect(ws.initialized).toBeTruthy()
      done()
