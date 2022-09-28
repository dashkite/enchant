command = ( object ) ->
  [ name ] = Object.keys object
  { name, bindings: object[ name ] }

isCommand = ( object ) -> object?.name && object?.bindings

addResponseHeader = ( context, key, value ) ->
  context.response.headers ?= {}
  context.response.headers[ key ] ?= []
  context.response.headers[ key ].push value

responseIsCacheable = ( context ) ->
  switch context.response.description
    when "ok", "created"
      context.response.content?
    else false

export {
  command
  isCommand
  addResponseHeader
  responseIsCacheable
}