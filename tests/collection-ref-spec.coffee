#
# Module dependencies.
#

protocol      = require '../src/protocol.coffee'
ReallyError   = require '../src/really-error.coffee'
Q             = require 'q'
_             = require 'lodash'
CollectionRef = require '../src/collection-ref.coffee'

describe 'CollectionRef', ->

  describe 'initialization', ->
    beforeEach ->
      ReallyMock = on: () -> undefined
      global.Really = ReallyMock

    afterEach ->
      global.Really = undefined

    it 'should take a resource as parameter', ->
      story = new CollectionRef('/stories/*')
      expect(story.res).toEqual '/stories/*'

    it 'should raise exception if constructor has no resource', ->
      expect ->
        story = new CollectionRef()
      .toThrow new ReallyError('Can not be initialized without resource')

  describe 'create', ->

    beforeEach ->
      ReallyMock = on: () -> undefined
      global.Really = ReallyMock

    afterEach ->
      global.Really = undefined

    it 'should call channel to send message with parameters', ->
      story =  new CollectionRef('/stories/*')

      story.channel =
        send: -> 'foo'

      spyOn(story.channel, 'send').and.callThrough()
      options =
        body: {
          name: 'Ihab',
          age: '99'
          }

        onSuccess: (data) ->
          console.log data

        onError: (error) ->
          console.log error.code # 403
          console.log error.message # forbidden

        onComplete: (data) ->
          console.log data

      message = protocol.createMessage(story.res, options.body)
      result = story.create(options)

      expect(story.channel.send).toHaveBeenCalledWith message,
      {success: options.onSuccess, error: options.onError, complete: options.onComplete}

    it 'should return a rejected promise when passing wrong options (options without body)', ->
      story = new CollectionRef(12)
      story.channel =
        send: -> 'foo'

      options =

        # body: {
        #   name: 'Ihab',
        #   age: '99'
        #   }

        onSuccess: (data) ->
          console.log data

        onError: (error) ->
          console.log error.code # 403
          console.log error.message # forbidden

        onComplete: (data) ->
          console.log data

      result = story.create(options)
      result.then null, (err) ->

        expect(err).toEqual new ReallyError('You should pass a body parameter as Object')



  describe 'read', ->
    beforeEach ->
      ReallyMock = on: () -> undefined
      global.Really = ReallyMock

    afterEach ->
      global.Really = undefined


    it 'should call channel to send message with parameters', ->
      story =  new CollectionRef('/stories/*')

      story.channel =
        send: -> 'foo'

      spyOn(story.channel, 'send').and.callThrough()

      options =
        fields: ['firstname', 'lastname', 'avatar']
        query:
          filter: 'name = {1} and age > {2}'
          values: ['Ahmed', 5]
        limit: 10
        sort: '-name'
        token: '23423423:1'
        skip: 1
        includeTotalCount: false
        subscribe: true

        onSuccess: (data) ->
          console.log data

        onError: (error) ->
          console.log error.code # 403
          console.log error.message # forbidden

        onComplete: (data) ->
          console.log data

      protocolOpttions = _.omit options, ['onSuccess', 'onError', 'onComplete']
      message = protocol.readMessage(story.res, protocolOpttions)
      result = story.read(options)

      expect(story.channel.send).toHaveBeenCalledWith message,
      {success: options.onSuccess, error: options.onError, complete: options.onComplete}

    it 'should return a rejected promise when passing wrong options', ->
      story = new CollectionRef('/stories/*')
      options =
        fields: ['firstname', 'lastname', 'avatar']
        query:
          filter: 'name = {1} and age > {2}'
          values: ['Ahmed', 5]
        limit: 10
        sort: '-name' #true
        token: '23423423:1'
        skip: 1
        includeTotalCount: false
        subscribe: true
        badParameter: false

      result = story.read(options)
      result.then null, (error) ->
        expect(error).toEqual new ReallyError('The option "badParameter" isn\'t supported')


