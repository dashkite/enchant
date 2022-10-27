import { register } from "./registry"
import { message } from "../messages"

register "rune", ({ parameters, credential }, { request }) ->
  { nonce } = parameters
  secret = await getSecret "guardian"
  if Runes.verify { rune: credential, nonce, secret }
    [ authorization ] = Runes.decode credential
    if ( requst = await Runes.match { request, authorization })?
      valid: true
    else
      valid: false
      reason: message "rune / request disallowed", { request }
  else
    valid: false
    reason: message "rune / verification failed", { request }
