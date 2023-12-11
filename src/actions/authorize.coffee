import log from "@dashkite/kaiko"
import { register } from "./registry"
import { message } from "../messages"
import { Authorizers } from "../authorizers"

# TODO we should probably just place error messages in the context
#      rather than deciding how to respond here

find = ( scheme, schemes ) ->
  schemes.find ( candidate ) -> candidate.scheme == scheme 

register "authorize", ( schemes, context ) ->
  log.debug authorization: "required"
  { request } = context
  if request.authorization?
    log.debug { schemes }
    for item in request.authorization
      { scheme, parameters } = item
      log.debug trying: scheme
      if !( match = find scheme, schemes )?
        log.warn disallowed: scheme
      else if !( authorize = Authorizers[ scheme ] )?
        log.warn unsupported: scheme
      else
        { options } = match
        log.debug authorizing: { parameters, options }
        if ( await authorize { parameters, options }, context ).valid
          return true
  log.debug authorization: "not provided"
  return false


