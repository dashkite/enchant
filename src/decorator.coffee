import * as Val from "@dashkite/joy/value"
import { Expression } from "./expression"

env = JSON.parse process.env.context

decorateMethods = ({ schemes, methods }) ->
  for key, method of methods
    method.request ?= {}
    method.request.authorization = schemes
    # ensure request comes before response for documentation generator
    if method.response?
      response = Val.clone method.response
      delete method.response
      method.response = response
    method.response ?= {}
    method.response.status ?= []
    method.response.status.push 401

decorator = ({ authorization }, handler ) ->
  authorization = Expression.apply authorization, { env }
  ( request ) ->
    response = await handler request
    { resource, domain } = request
    if resource.name == "description"
      description = response.content
      if ( auth_description = ( authorization.find ( element ) -> element.domain == domain ))?
        { include, exclude, schemes } = auth_description
        if include?
          for name in include
            decorateMethods { schemes, methods: description.resources[name].methods }
        else if exclude?
          for name of description.resources
            if !( name in exclude )
              decorateMethods { schemes, methods: description.resources[name].methods }
        else
          throw new Error "missing include or exclude in authorization description", domain
      response.content = description
    response

export {
  decorator
}
