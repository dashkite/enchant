import { Actions } from "./actions"

Match =

  Resource:
    
    condition: ( conditions, { name }) ->
      ->
        conditions.find ( condition ) ->
          condition.name == "resource" && condition.value? &&
            Actions.resource condition.value, request: { resource: name }

    wildcard: ( conditions ) ->
      -> 
        conditions.every ( condition ) ->
          condition.name != "resource"

  Method:

    condition: ( conditions, { name }) ->
      -> 
        conditions.find ( condition ) ->
          condition.name == "method" && condition.value? &&
            Actions.method condition.value, request: { method: name }
  
    wildcard: ( conditions ) ->
      ->
        conditions.every ( condition ) ->
          condition.name != "resource"

Filter =

  resource: ( resource ) ->
    ({ conditions }) ->
      ( Match.Resource.condition conditions, resource ) ||
        ( Match.Resource.wildcard conditions )
    
  method: ( method ) ->
    ({ conditions }) ->
      ( Match.Method.condition conditions, method ) ||
        ( Match.Method.wildcard conditions, method )

Map =

  schemes: ({ actions }) ->
    actions
      .filter ( action ) -> action.name == "authorization"
      .map ({ value }) -> value
      .reduce [], ( schemes, _schemes ) -> [ schemes..., _schemes... ]

  nullify: ( schemes ) -> 
    if schemes.length == 0 then null else schemes

match = ( rules, resource, method ) ->
  rules
    .filter Filter.resource resource
    .filter Filter.method method
    .map Map.schemes
    .map Map.nullify

decorator = ( policies, handler ) ->
  ( request ) ->
    response = await handler request
    { resource, domain } = request
    if resource.name == "description" && policies[ domain ]?
      description = API.Description.from response.content
      rules = policies[ domain ].request
      for resource in description
        for method in resource
          if ( schemes = match rules, resource, method )?
            method.authorization = schemes
      response.content = descripton.data
    response

export {
  decorator
}
