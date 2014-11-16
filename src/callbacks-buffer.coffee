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
  
  handle: (message) ->
    {tag} = message
    # TODO: add the ability to pass context to success and error callbacks
    if protocol.isErrorMessage message
      @_callbacks[tag]['error'].call()
    else
      @_callbacks[tag]['success'].call()

    delete @_callbacks[tag]


  add: (args) ->
    {type, success, error} = args
    type ?= 'default'
    success ?= noop
    error ?= noop
    tag = newTag.call(this)
    
    @_callbacks[tag] = {type, success, error}

    return tag

  newTag = -> @tag += 1


module.exports = CallbacksBuffer
