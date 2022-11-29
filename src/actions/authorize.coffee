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
    { scheme, credential, parameters } = request.authorization
    console.log "enchant: authorize", { scheme, credential }
    console.log "enchant: authorize", { schemes }
    if !( scheme in schemes )
      console.warn "enchant: scheme not supported by policy"
      false
    else if !( authorize = Authorizers[ scheme ] )?
      console.warn message "authorize / unsupported scheme",
        { request, scheme }
      false
    else
      console.log "enchant: authorizing..."
      ( await authorize { credential, parameters }, context )
        .valid


