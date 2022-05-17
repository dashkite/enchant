command = ( object ) ->
  [ name ] = Object.keys object
  { name, bindings: object[ name ] }

isCommand = ( object ) -> object?.name && object?.bindings


export {
  command
  isCommand
}