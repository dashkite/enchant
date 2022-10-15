import { Rules } from "./rules"

Policy =

  apply: ( context, policy ) ->
    { request, response } = policy
    if request?.rules?
      await Rules.Request.apply request.rules, context
    if response?.rules?
      Rules.Response.apply response.rules, context

Policies =

  find: ( policies, resource ) ->

    { domain } = resource

    policies[ domain ].filter ( policy ) ->
      if policy.resources?
        policy.resources.find ( candidate ) ->
          if candidate.include?
            resource.name in candidate.include
          else if candidate.exclude?
            !( resource.name in candidate.exclude )
      # else include all resources
      else true
  
  apply: ( policies, context ) ->

    { request, fetch } = context
    { resource } = request

    for policy in Policies.find resource, policies
      await Policy.apply context, policy

    context.response ?= await fetch request

export {
  Policy
  Policies
}