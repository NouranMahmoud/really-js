#
# Module dependencies.
#

protocol            = require '../src/protocol.coffee'
ReallyError         = require '../src/really-error.coffee'
Q                   = require 'q'
ObjectRef           = require '../src/object-ref.coffee'

describe 'ObjectRef', ->

  describe 'initialization', ->

    it 'should take a resource as parameter', ->
      user = new ObjectRef '/users/123'
      expect(user.res).toEqual '/users/123'

    it 'should raise exception if constructor has no resource', ->
      expect ->
        user = new ObjectRef
      .toThrow new ReallyError 'Can not connect without resource'

  describe 'get', ->

    it 'should raise an exception when there are no passed options ', ->
      user = new ObjectRef '/users/123/'
      result = user.get()
      expect(typeof result.then == "function").toBeTruthy()
      result.then null, (err) ->
        expect(err).toThrow new ReallyError 'Can\'t be called without passing arguments'

    it 'should call channel to send message', ->
      user =  new ObjectRef('/users/123/')
      user.channel =
        send: -> "foo"

      spyOn(user.channel, 'send')

      options =
        fields: ["author", "@card"]

        onSuccess: (data) ->
          console.log data

        onError: (error) ->
          console.log error.code # 403
          console.log error.message # forbidden

      result = user.get(options)
      expect(user.channel.send()).toHaveBeenCalled

  describe 'update', ->
    it 'should raise an exception when there are no passed options ', ->
      user = new ObjectRef '/users/123/'
      result = user.update()
      expect(typeof result.then == "function").toBeTruthy()
      result.then null, (err) ->
        expect(err).toThrow new ReallyError 'Can\'t be called without passing arguments'

    it 'should call channel to send message', ->
      user =  new ObjectRef('/users/123/')
      user.channel =
        send: -> "foo"

      spyOn(user.channel, 'send')
      onSuccess = (data) -> console.log data
      options =
        onSuccess: onSuccess
        ops: [
            {
              key: "friends"
              op: "set"
              value: "Ahmed"
            }
            {
              key: "picture.xlarge"
              op: "set"
              value: "http://koko.com/toto.png"
            }
            {
              key: "picture[0]"
              op: "set"
              value:
                xlarge: "http://koko.toto.png"
            }
            {
              key: "age"
              op: "add-number"
              value: 1
            }
          ]
      result = user.update(options)
      expect(user.channel.send()).toHaveBeenCalled

  describe 'delete', ->

    it 'should call channel to send message', ->

      user = new ObjectRef '/users/123/'
      user.channel =
        send: -> "foo"
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
      expect(user.channel.send()).toHaveBeenCalled
