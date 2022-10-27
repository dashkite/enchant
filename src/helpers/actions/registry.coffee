Actions = {}

register = ( name, handler ) ->
  Actions[ name ] = handler

export {
  register
  Actions 
}