import log from "@dashkite/kaiko"

Actions = {}

register = ( name, handler ) ->
  Actions[ name ] = log.wrap name, handler

export {
  register
  Actions 
}