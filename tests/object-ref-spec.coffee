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

    it 'should raise exception if resource is not string', ->
      expect ->
        user = new ObjectRef(123)
      .toThrow new ReallyError('You should pass a resource parameter as String')

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

      spyOn(user.channel, 'send')

      options =
        fields: ['author', '@card']

        onSuccess: (data) ->
          console.log data

        onError: (error) ->
          console.log error.code # 403
          console.log error.message # forbidden
        onComplete: (data) ->
          console.log data

      message =
        type: 'get'
        data:
          cmd: 'get'
          r: user.res
          cmdOpts:
            fields: options.fields

      spyOn(protocol, 'getMessage').and.returnValue message


      result = user.get(options)
      expect(user.channel.send).toHaveBeenCalledWith message,
        success: options.onSuccess
        error: options.onError
        complete: options.onComplete

    it 'should call channel to send without callbacks', ->
      user =  new ObjectRef('/users/123/')

      user.channel =
        send: -> 'foo'

      spyOn(user.channel, 'send')

      options =
        fields: ['author', '@card']

      message =
        type: 'get'
        data:
          cmd: 'get'
          r: user.res
          cmdOpts:
            fields: options.fields

      spyOn(protocol, 'getMessage').and.returnValue message


      result = user.get(options)

      expect(user.channel.send).toHaveBeenCalledWith message,
        success: undefined
        error: undefined
        complete: undefined

  describe 'update', ->

    beforeEach ->
      ReallyMock = on: () -> undefined
      global.Really = ReallyMock

    afterEach ->
      global.Really = undefined

    it 'should return rejected promise when there are no passed options', (done) ->
      user = new ObjectRef('/users/123/')
      result = user.update()

      expect(typeof result.then is 'function').toBeTruthy()
      expect(result.isRejected()).toBeTruthy()

      result.catch (err) ->
        expect(err).toEqual new ReallyError('Can\'t be called without passing arguments')
        done()

    it 'should call channel to send message with message and options ', ->
      user =  new ObjectRef('/users/123/')
      user.channel =
        send: -> 'foo'

      spyOn(user.channel, 'send')

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

      message =
        type: 'update'
        data:
          cmd: 'update'
          rev: user.rev
          r: user.res
          body:
            ops: options.ops

      spyOn(protocol, 'updateMessage').and.returnValue message

      result = user.update(options)
      expect(user.channel.send).toHaveBeenCalledWith message,
        success: options.onSuccess
        error: options.onError
        complete: options.onComplete

    it 'should call channel to send message without callbacks ', ->
      user =  new ObjectRef('/users/123/')
      user.channel =
        send: -> 'foo'

      spyOn(user.channel, 'send')

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

      message =
        type: 'update'
        data:
          cmd: 'update'
          rev: user.rev
          r: user.res
          body:
            ops: options.ops

      spyOn(protocol, 'updateMessage').and.returnValue message

      result = user.update(options)
      expect(user.channel.send).toHaveBeenCalledWith message,
        success: undefined
        error: undefined
        complete: undefined

    it 'should return rejected promise if there are no passed ops', (done) ->
      user =  new ObjectRef('/users/123/')
      user.channel =
        send: -> 'foo'

      spyOn(user.channel, 'send')

      options =
        ops: []
        onSuccess: (data) ->
          console.log data
        onError: (error) ->
          console.log error.code # 403
          console.log error.message # forbidden
        onComplete: (data) ->
          console.log data

      result = user.update(options)
      result.catch (err) ->
        expect(err).toEqual new ReallyError('You should pass at least one operation')
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

      message =
        type: 'delete'
        data:
          cmd: 'delete'
          r: user.res

      spyOn(protocol, 'updateMessage').and.returnValue message


      expect(user.channel.send).toHaveBeenCalledWith message,
        success: options.onSuccess
        error: options.onError
        complete: options.onComplete
