#
# Module dependencies.
#
protocol        = require '../src/protocol.coffee'
CallbacksBuffer = require '../src/callbacks-buffer.coffee'
ReallyError     = require '../src/really-error.coffee'

describe 'CallbacksBuffer', ->

  describe 'initialization', ->

    it 'should initiate a variable tag with 0', ->
      buffer = new CallbacksBuffer()
      expect(buffer.tag).toEqual 0

    it 'should create empty object for callbacks', ->
      buffer = new CallbacksBuffer()
      expect(buffer._callbacks).toEqual {}

  describe 'handle', ->
    it 'should raise exception if a message without tag is passed', ->
      buffer = new CallbacksBuffer()
      messageWithoutTag = {error: true}
      expect ->
        buffer.handle(messageWithoutTag)
      .toThrow new ReallyError('A message with tag should be passed');

    it 'should throw error if the complete callback raised exception', ->
      buffer = new CallbacksBuffer()
      message =
        tag: 5
      complete = (data) ->
        throw new Error('error')

      success = (data) ->
        console.log 'success'

      buffer._callbacks[5] = {type: 'default', success, complete}


      expect ->
        buffer.handle(message)
      .toThrow new ReallyError('Error happened when trying to execute your error callback')

    it 'should throw error if the success callback raised exception', ->
      buffer = new CallbacksBuffer()
      message =
        tag: 5
        success: true

      complete = (data) ->
        console.log 'complete'
      success = (data) ->
        throw new Error('error')

      buffer._callbacks[5] = {type: 'default', success, complete}

      expect ->
        buffer.handle(message)
      .toThrow new ReallyError('Error happened when trying to execute your error callback')

    it 'should throw error if the error callback raised exception', ->
      buffer = new CallbacksBuffer()
      message =
        tag: 5
        error: true

      complete = (data) ->
        console.log 'complete'
      error = (data) ->
        throw new Error('error')

      buffer._callbacks[5] = {type: 'default', error, complete}

      expect ->
        buffer.handle(message)
      .toThrow new ReallyError('Error happened when trying to execute your error callback')


    it 'should invoke the error callback if the message is error message', ->
      buffer = new CallbacksBuffer()
      errorMessage =
        tag: 5
        error: true

      options =
        error: (reason) ->
          console.log 'error'

        complete: (data) ->
          console.log 'complete'

      spy = spyOn(options, 'error')
      buffer._callbacks[5] = {type: 'default', error: options.error, complete: options.complete}

      buffer.handle(errorMessage)
      expect(options.error).toHaveBeenCalled()


    it 'should invoke the success callback if the message is success message', ->
      buffer = new CallbacksBuffer()
      errorMessage  =
        tag: 5
        success: true

      options =
        success: (data) ->
          console.log 'success'

        complete: (data) ->
          console.log 'complete'

      spy = spyOn(options, 'success')
      buffer._callbacks[5] = {type: 'default', success: options.success, complete: options.complete}

      buffer.handle(errorMessage)
      expect(options.success).toHaveBeenCalled()

    it 'should invoke the complete callback', ->
      buffer = new CallbacksBuffer()
      message =
        tag: 5
        success: true

      options =
        success: (data) ->
          console.log 'success'
        complete: (data) ->
          console.log 'complete'

      spyOn(options, 'complete')
      buffer._callbacks[5] = {type: 'default', success: options.success, complete: options.complete}

      buffer.handle(message)
      expect(options.complete).toHaveBeenCalled()


    it 'should delete the tag after invoking its callbacks', ->
      buffer = new CallbacksBuffer()
      message =
        tag: 5

      success = (data) ->
        console.log 'success'

      complete = (data) ->
        console.log 'complete'

      buffer._callbacks[5] = {type: 'default', success, complete}

      buffer.handle(message)

      expect(buffer._callbacks[5]).toBeUndefined()

    it 'should throw ReallyError when tag does not exist', ->
      buffer = new CallbacksBuffer()
      message =
        tag: 5
        success: true

      expect ->
        buffer.handle(message)
      .toThrow new ReallyError('The tag does not exist')

  describe 'add', ->

    it 'should return new tag when not passing args', ->
      buffer = new CallbacksBuffer()
      expect(buffer.tag).toEqual 0
      tag = buffer.add()
      expect(tag).toEqual 1

    it 'should return new tag when passing args', ->
      buffer = new CallbacksBuffer()
      expect(buffer.tag).toEqual 0
      type = 'add'

      success = (data) ->
        console.log data

      error = (reason) ->
        console.log reason

      complete = (data) ->
        console.log data

      tag = buffer.add {type, success, error, complete}
      expect(tag).toEqual 1
