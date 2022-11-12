import { register } from "./registry"
import { message } from "../messages"
import { Authorizers } from "../authorizers"

# TODO we should probably just place error messages in the context
#      rather than deciding how to respond here
register "authorize", ( schemes, context ) ->
  { request } = context
  if request.authorization?
    { scheme, credential, parameters } = request.authorization
    { nonce } = parameters
    if (( scheme in schemes ) && authorize = Authorizers[ scheme ] )?    
      result = await authorize { credential, parameters }, context
      if result.valid
        true
      else
        context.response =
          description: "unauthorized"
          content: result.reason
        false
    else
      context.response =
        description: "unauthorized"
        content: message "authorize / unsupported scheme", { request, scheme }
      false
  else
    context.response =
      description: "unauthorized"
      content: message "authorize / required", { request, scheme }
    false


