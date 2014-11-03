customMatchers =
  toBeString: ->
    compare: (actual) ->
      result = 
        pass: typeof actual is 'string'
      if result.pass
        result.message = actual + ' is string type'
      else
        result.message = actual + ' is not string type'
      result

module.exports = customMatchers
