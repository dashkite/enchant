import { register } from "./registry"
import { message } from "../messages"

register "authorize", ( schemes, context ) ->
  { request } = context
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
    content.response =
      description: "unauthorized"
      content: messages "authorize / unsupported scheme", { request, scheme }

