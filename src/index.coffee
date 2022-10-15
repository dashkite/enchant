import {
  response
} from "@dashkite/maeve/sublime"

import {
  Resource
  Policies
  decorate
} from "./helpers"

enchant = ( policies, fetch ) ->
  decorate policies, ( request ) ->
    context = { request, fetch }
    if ( resource = await Resource.find context )?
      request.resource = resource
      await Policies.apply policies, context
    else
      response "not found"