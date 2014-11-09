
module.exports =
  handle: (message) ->
    switch message.evt
      when 'kicked'
        console.log 'kicked'
      when 'revoked'
        console.log 'revoked'
      else
        console.log 'unknown event'

      
    
