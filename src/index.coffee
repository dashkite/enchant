import {
  response
} from "@dashkite/maeve/sublime"

import {
  Resource
  Rules
  decorate
} from "./helpers"

enchant = ( policies, fetch ) ->
  decorate policies, ( request ) ->
    context = { request, fetch }
    if ( resource = await Resource.find context )?
      request.resource = resource
      await Rules.apply context, policies
    else
      response "not found"