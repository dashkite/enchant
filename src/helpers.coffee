command = ( object ) ->
  [ name ] = Object.keys object
  { name, bindings: object[ name ] }

isCommand = ( object ) -> object?.name && object?.bindings

addResponseHeader = ( context, key, value ) ->
  ( context.response.headers[ key ] ?= [] )
    .push value

export {
  command
  isCommand
  addResponseHeader
}