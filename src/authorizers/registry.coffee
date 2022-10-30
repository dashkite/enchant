Authorizers = {}

register = ( name, handler ) ->
  Authorizers[ name ] = handler

export {
  register
  Authorizers 
}