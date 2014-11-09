Channel = require './transports/webSocket.coffee'
# Authenticaiton = require './src/authenticaiton.coffee'
Emitter = require 'component-emitter'

class Really
  constructor: (domain) ->
    console.log 'Really Object initialized'
    # authenticationPromise = null
    
    # authentication.login().done (data) =>
    #   @channel = new domain, data.accessToken
    #   authenticationPromise = @channel.connect()

    # authenticationPromise.done () =>
    #   @emit 'really:started'
   
  Emitter(Really.prototype) 
  
  


module.exports = Really
