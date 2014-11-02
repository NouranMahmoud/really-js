Transport = require '../transport.coffee'
ReallyError = require '../really-error.coffee'
WebSocket = require 'ws'
protocol = require '../protocol.coffee'

class WebSocketTransport extends Transport
  constructor: (doamin, secure=false) ->
    throw new ReallyError 'can\'t initialize connection without passing URL' unless doamin
    transportProtocol = if secure then 'wss' else 'ws'
    @url = "#{transportProtocol}://#{doamin}/v#{protocol.clientVersion}/websocket"

  connect: (authenticationToken) ->
    console.log @url
    @socket = new WebSocket @url
    @socket.onopen = =>
      @send protocol.getInitializationMessage(authenticationToken)

  disconnect: () ->

  send: (message) ->
    @socket.send JSON.stringify message

  isConnected: () ->
    if @socket
      @socket.readyState is @socket.OPEN
    else false
  
  on: (eventName, callback) ->
    switch eventName
      when 'message'
        @socket.addEventListener 'message', (e)-> 
          callback JSON.parse e.data

module.exports = WebSocketTransport
