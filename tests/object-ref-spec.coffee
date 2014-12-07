#
# Module dependencies.
#

protocol            = require '../src/protocol'
ReallyError         = require '../src/really-error'
Q                   = require 'q'
ObjectRef           = require '../src/object-ref'

describe 'ObjectRef', ->

  describe 'initialization', ->

    beforeEach ->
      ReallyMock = on: () -> undefined
      global.Really = ReallyMock

    afterEach ->
      global.Really = undefined

    it 'should take a resource as parameter', ->
      user = new ObjectRef('/users/123')
      expect(user.res).toEqual '/users/123'

    it 'should raise exception if constructor has no resource', ->
      expect ->
        user = new ObjectRef()
      .toThrow new ReallyError('Can not be initialized without resource')

  describe 'get', ->

    beforeEach ->
      ReallyMock = on: () -> undefined
      global.Really = ReallyMock

    afterEach ->
      global.Really = undefined

    it 'should call channel to send with message and options', ->
      user =  new ObjectRef('/users/123/')

      user.channel =
        send: -> 'foo'

      spyOn(user.channel, 'send').and.callThrough()
      options =
        fields: ['author', '@card']

        onSuccess: (data) ->
          console.log data

        onError: (error) ->
          console.log error.code # 403
          console.log error.message # forbidden

      message = protocol.getMessage(user.res, options.fields)
      result = user.get(options)
      expect(user.channel.send).toHaveBeenCalledWith(message,
      {success: options.onSuccess, error: options.onError, complete: options.onComplete})

    it 'should call channel to send without callbacks', ->
      user =  new ObjectRef('/users/123/')

      user.channel =
        send: -> 'foo'

      spyOn(user.channel, 'send').and.callThrough()
      options =
        fields: ['author', '@card']

      message = protocol.getMessage(user.res, options.fields)
      result = user.get(options)
      expect(user.channel.send).toHaveBeenCalledWith(message,
      {success: options.onSuccess, error: options.onError, complete: options.onComplete})
    it 'should return rejected promise if ther\' no fields', (done) ->
      user =  new ObjectRef('/users/123/')

      user.channel =
        send: -> 'foo'

      spyOn(user.channel, 'send').and.callThrough()
      options =
        onSuccess: (data) ->
          console.log data

        onError: (error) ->
          console.log error.code # 403
          console.log error.message # forbidden

      result = user.get(options)
      result.then null, (err) ->
        expect(err).toEqual new ReallyError('You should pass array or nothing for fields option')
        done()

  describe 'update', ->

    beforeEach ->
      ReallyMock = on: () -> undefined
      global.Really = ReallyMock

    afterEach ->
      global.Really = undefined

    it 'should reject the promise when there are no passed options', (done) ->
      user = new ObjectRef('/users/123/')
      result = user.update()
      expect(typeof result.then is 'function').toBeTruthy()
      expect(result.isRejected()).toBeTruthy()
      result.then null, (err) ->
        expect(err).toEqual new ReallyError('Can\'t be called without passing arguments')
        done()

    it 'should call channel to send message with message and options ', ->
      user =  new ObjectRef('/users/123/')
      user.channel =
        send: -> 'foo'

      spyOn(user.channel, 'send').and.callThrough()

      options =
        onSuccess: (data) -> console.log data
        onError: (err) -> console.log err
        onComplete: (data) -> console.log data
        ops: [
            {
              key: 'friends'
              op: 'set'
              value: 'Ahmed'
            }
            {
              key: 'picture.xlarge'
              op: 'set'
              value: 'http://koko.com/toto.png'
            }
            {
              key: 'picture[0]'
              op: 'set'
              value:
                xlarge: 'http://koko.toto.png'
            }
            {
              key: 'age'
              op: 'addNumber'
              value: 1
            }
          ]
      message = protocol.updateMessage(user.res, user.rev, options.ops)
      result = user.update(options)
      expect(user.channel.send).toHaveBeenCalledWith(message,
        {success: options.onSuccess, error: options.onError, complete: options.onComplete})

    it 'should call channel to send message without callbacks ', ->
      user =  new ObjectRef('/users/123/')
      user.channel =
        send: -> 'foo'

      spyOn(user.channel, 'send').and.callThrough()

      options =
        ops: [
            {
              key: 'friends'
              op: 'set'
              value: 'Ahmed'
            }
            {
              key: 'picture.xlarge'
              op: 'set'
              value: 'http://koko.com/toto.png'
            }
            {
              key: 'picture[0]'
              op: 'set'
              value:
                xlarge: 'http://koko.toto.png'
            }
            {
              key: 'age'
              op: 'addNumber'
              value: 1
            }
          ]
      message = protocol.updateMessage(user.res, user.rev, options.ops)
      result = user.update(options)
      expect(user.channel.send).toHaveBeenCalledWith(message,
        {success: options.onSuccess, error: options.onError, complete: options.onComplete})

    it 'should return rejected promise if ther\' no passed ops', (done) ->
      user =  new ObjectRef('/users/123/')

      user.channel =
        send: -> 'foo'

      spyOn(user.channel, 'send').and.callThrough()
      options =
        ops: []
        onSuccess: (data) ->
          console.log data
        onError: (error) ->
          console.log error.code # 403
          console.log error.message # forbidden
        onComplete: (data) ->
          console.log data

      result = user.get(options)
      result.then null, (err) ->
        expect(err).toEqual new ReallyError('You should pass array or nothing for fields option')
        done()

  describe 'delete', ->

    beforeEach ->
      ReallyMock = on: () -> undefined
      global.Really = ReallyMock

    afterEach ->
      global.Really = undefined

    it 'should call channel to send message', ->
      user = new ObjectRef('/users/123/')
      user.channel =
        send: -> 'foo'
      options =
        onSuccess: (data) ->
          console.log data
        onError: (error) ->
          console.log error.code # 403
          console.log error.message # forbidden
        onComplete: (data) ->
          console.log data

      spyOn(user.channel, 'send')
      result = user.delete(options)
      message = protocol.deleteMessage(user.res)
      expect(user.channel.send).toHaveBeenCalledWith(message,
        {success: options.onSuccess, error: options.onError, complete: options.onComplete})
