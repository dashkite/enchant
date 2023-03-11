import { Rules } from "../rules"
import { register } from "./registry"

# TODO reconcile with Policies.apply
register "apply", ( value, context ) ->
  if value?
    for policy in value.policies when policy.request?
      # console.log "enchant: request policy", policy
      await Rules.Request.apply policy.request, context
    
    if context.response?
      for policy in value.policies when policy.response?
        await Rules.Response.apply policy.response, context