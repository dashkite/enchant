import { register } from "./registry"
import { message } from "../messages"
import { Authorizers } from "../authorizers"

# TODO we should probably just place error messages in the context
#      rather than deciding how to respond here
register "authorize", ( schemes, context ) ->
  console.warn "enchant: attempt authorization"
  { request } = context
  if request.authorization?
    console.warn "enchant: authorization defined"
    for item in request.authorization
      { scheme, credential, parameters } = item
      console.log "enchant: authorize", { scheme, credential }
      console.log "enchant: authorize", { schemes }
      if !( scheme in schemes )
        console.warn "enchant: scheme not supported by policy"
      else if !( authorize = Authorizers[ scheme ] )?
        console.warn message "authorize / unsupported scheme",
          { request, scheme }
      else
        console.log "enchant: authorizing..."
        if ( await authorize { credential, parameters }, context ).valid
          return true
  return false


