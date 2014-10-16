WebSocketServer = require('ws').Server
CONFIG = require './config'
console.log CONFIG
wss = new WebSocketServer 
  port: CONFIG.WEBSOCKET_SERVER_PORT

wss.on 'connection', (ws) ->
  ws.on 'message', (message) ->
    console.log 'received: %s', message
    ws.send message

module.exports = wss
