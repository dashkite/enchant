import { Rules } from "./rules"
import { registry } from "./registry"

Policies =

  apply: ({ policies }, request ) ->

    context = { request, registry }

    for policy in policies when policy.request?
      # console.log "enchant: request policy", policy
      await Rules.Request.apply policy.request, context
    
    # forward is effectively the default request policy
    context.response ?= await Sky.fetch request

    for policy in policies when policy.response?
      await Rules.Response.apply policy.response, context

    context.response

export {
  Policies
}