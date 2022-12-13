decorateMethods = ({ schemes, methods }) ->
  for key, method of methods
    method.request ?= {}
    method.request.authorization = schemes
    method.response ?= {}
    method.response.status ?= []
    method.response.status.push 401

decorator = ({ authorization }, handler ) ->
  ( request ) ->
    response = await handler request
    { resource, domain } = request
    if resource.name == "description"
      description = response.content
      if authorization[domain]?
        { include, exclude, schemes } = authorization[domain]
        if include?
          for name in include
            decorateMethods { schemes, methods: description.resources[name].methods }
        else if exclude?
          for name of description.resources
            if !( name in exclude )
              decorateMethods { schemes, methods: description.resources[name].methods }
        else
          throw failure "missing include or exclude in authorization description", domain
      response.content = description
    response

export {
  decorator
}
