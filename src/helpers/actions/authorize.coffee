import { register } from "./registry"
import { Authorizers } from "../authorizers"
import { message } from "../messages"

register "authorize", ( value, context ) ->
  { request } = context
  # TODO classifier should set this up?
  { scheme, credential, parameters } = request.authorization
  { nonce } = parameters
  if ( authorize = Authorizers[ scheme ] )?    
    result = authorize { credential, parameters }, request
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

