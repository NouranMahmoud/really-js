###*
 * Protocol 
 * This module is responsible for generating protocol messages
###
VERSION = '0'
module.exports = 
  
  clientVersion: VERSION

  commands:
    'init': 'init'
    'create': 'create'
    'read': 'read'
    'update': 'update'
    'delete': 'delete'

  getInitializationMessage: (authToken) ->
    'cmd': @commands.init
    'authToken': authToken

  createMessage: (res) ->
    cmd: @commands.create
    res: res
