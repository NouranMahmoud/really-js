WebSocketServer = require('ws').Server
CONFIG = require './config'
wss = new WebSocketServer(port: CONFIG.REALLY_PORT)

wss.on 'connection', (ws) ->
  ws.on 'message', (message) ->
    msg = JSON.parse message
    if msg.cmd is 'error'
      msg.error = true
      ws.send  JSON.stringify msg
      console.log "Received #{JSON.stringify msg}"
      console.log 'Error message'
    else
      ws.send message
      console.log "Received #{message}"
      console.log 'Success message'

module.exports = wss
