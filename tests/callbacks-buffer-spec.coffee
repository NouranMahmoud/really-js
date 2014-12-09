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
      .toThrow new ReallyError('A message should be passed');


    it 'should invoke the error callback if the message is error message', ->
      buffer = new CallbacksBuffer()
      messageIsSuccess = true
      messageWithError    = {tag: 5, error: true }

      success = (data) ->
        console.log 'success'
      error = (reason) ->
        console.log 'error'
        messageIsSuccess = false
      complete = (data) ->
        console.log 'complete'

      buffer._callbacks[5] = {'default', success, error, complete}
      buffer.handle(messageWithError)
      setTimeout (->
        expect(messageIsSuccess).toBeFalsy()
      ), 1000

    it 'should invoke the success callback if the message is success message', ->
      buffer = new CallbacksBuffer()
      messageIsSuccess = false
      messageWithoutError    = {tag: 5, success: true }

      success = (data) ->
        console.log 'success'
        messageIsSuccess = true
      error = (reason) ->
        console.log 'error'
      complete = (data) ->
        console.log 'complete'

      buffer._callbacks[5] = {'default', success, error, complete}
      buffer.handle(messageWithoutError)
      setTimeout (->
        expect(messageIsSuccess).toBeTruthy()
      ), 1000

    it 'should invoke the complete callback', ->
      buffer = new CallbacksBuffer()

      messageIsSuccess = false
      messageIsComplete = false
      messageWithoutError    = {tag: 5, success: true }

      success = (data) ->
        console.log 'success'
        messageIsSuccess = true
      error = (reason) ->
        console.log 'error'
      complete = (data) ->
        console.log 'complete'
        messageIsComplete = true

      buffer._callbacks[5] = {'default', success, error, complete}
      buffer.handle(messageWithoutError)
      setTimeout (->
        expect(messageIsSuccess).toBeTruthy()
        expect(messageIsComplete).toBeTruthy()
      ), 1000

    it 'should delete the tag after invoking its callbacks', ->
      buffer = new CallbacksBuffer()
      messageWithoutError    = {tag: 5, success: true }

      success = (data) ->
        console.log 'success'
        messageIsSuccess = true
      error = (reason) ->
        console.log 'error'
      complete = (data) ->
        console.log 'complete'
        messageIsComplete = true

      buffer._callbacks[5] = {'default', success, error, complete}
      buffer.handle(messageWithoutError)

      expect(buffer._callbacks[5]).toBeUndefined()

    it 'should throw ReallyError when tag does not exist', ->
      buffer = new CallbacksBuffer()
      message = {tag: 5, success: true }

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
      {type} = 'add'

      success = (data) ->
        console.log data

      error = (reason) ->
        console.log reason

      complete = (data) ->
        console.log data

      tag = buffer.add {type, success, error, complete}
      expect(tag).toEqual 1

  describe 'newTag', ->
    it 'should increment the tag', ->
      buffer = new CallbacksBuffer()
      expect(buffer.tag).toEqual 0
      spyOn(buffer, 'add').and.callFake ->
        tag = newTag.call(buffer)
        expect(tag).toEqual 1
