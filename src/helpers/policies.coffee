import { Rules } from "./rules"
Policies =

  apply: ( policies, request ) ->

    { domain } = request
    context = { request }

    policy = policies[ domain ] ? {}

    if ( rules = policy.request )?
      await Rules.Request.apply rules, context
    
    # forward is effectively the default request policy
    context.response ?= await Sky.fetch request

    if ( rules = policy.response )?
      await Rules.Repsonse.apply rules, context

    context.response

export {
  Policies
}