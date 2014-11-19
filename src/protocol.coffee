###*
 * Protocol 
 * This module is responsible for generating protocol messages
###
_ = require 'lodash'
authenticator = require './authenticator.coffee'

VERSION = '0'
module.exports = 
  
  clientVersion: VERSION

  commands:
    'init': 'init'
    'create': 'create'
    'read': 'read'
    'update': 'update'
    'delete': 'delete'
    'heartbeat': 'poke'

  getInitializationMessage: () ->
    'type': 'initialization'
    'data':
      'cmd': @commands.init
      'accessToken': authenticator.getAccessToken()

  createMessage: (res) ->
    type: 'create'
    data:
      cmd: @commands.create
      res: res

  heartbeatMessage: () ->
    time = Date.now()
    
    type: 'poke'
    data:
      cmd: @commands.heartbeat
      timestamp: time

  isErrorMessage: (message) -> _.has message, 'error'
