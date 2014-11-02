###*
 * Copyright (C) 2014-2015 Really Inc. <http://really.io>
 * 
 * Callbacks Buffer
 * 
###
protocol = require './protocol.coffee'
class CallbacksBuffer
  constructor: ->
    @tag = 0
    @_callbacks = {}

  noop = ->
  
  handle = (message) ->
    {tag, success, error} = message
    # TODO: add the ability to pass context to success and error callbacks
    if protocol.isErrorMessage message
      setTimeout @_callbacks[tag]['error'], 0
    else
      etTimeout @_callbacks[tag]['success'], 0


  add: (args) ->
    {type, success, error} = args
    type ?= 'default'
    success ?= noop
    error ?= noop
    
    tag = newTag()
    
    @_callbacks[tag] = {type, success, error}

  newTag = -> @tag += 1


module.exports = CallbacksBuffer
