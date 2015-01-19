WebSocketServer = require('ws').Server
CONFIG = require './config'
wss = new WebSocketServer(port: CONFIG.REALLY_PORT)

wss.on 'connection', (ws) ->
  ws.on 'message', (message) ->
    console.log "***Error message Received: #{message}***" if (JSON.parse message).error
    ws.send message
    console.log "Success message Received: #{message}"

module.exports = wss
