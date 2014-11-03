###*
 * Protocol 
 * This module is responsible for generating protocol messages
###
_ = require 'lodash'

VERSION = '0'
module.exports = 
  
  clientVersion: VERSION

  commands:
    'init': 'init'
    'create': 'create'
    'read': 'read'
    'update': 'update'
    'delete': 'delete'

  getInitializationMessage: () ->
    'type': 'initialization'
    'data':
      'cmd': @commands.init

  createMessage: (res) ->
    cmd: @commands.create
    res: res

  isErrorMessage: (message) -> _.has message, 'error'
