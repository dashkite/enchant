import * as Obj from "@dashkite/joy/object"
import { Actions } from "./actions"
import * as API from "@dashkite/sky-api-description"

# TODO: bug in Arr.cat b/c variadic
cat = ( a, b ) -> [ a..., b... ]

nullify = ( schemes ) -> 
  if schemes.length == 0 then null else schemes

Match =

  Domain:
    
    condition: ( conditions, name ) ->
      conditions.find ( condition ) ->
        condition.name == "domain" && condition.value? &&
          Actions.domain condition.value, { request: { domain: name }}

    wildcard: ( conditions ) ->
      conditions.every ( condition ) ->
        condition.name != "domain"

  Resource:
    
    condition: ( conditions, { name }) ->
      conditions.find ( condition ) ->
        condition.name == "resource" && condition.value? &&
          Actions.resource condition.value, { request: { resource: { name }}}

    wildcard: ( conditions ) ->
      conditions.every ( condition ) ->
        condition.name != "resource"

  Method:

    condition: ( conditions, name ) ->
      conditions.find ( condition ) ->
        condition.name == "method" && condition.value? &&
          Actions.method condition.value, { request: { method: name } }
  
    wildcard: ( conditions ) ->
      conditions.every ( condition ) ->
        condition.name != "method"

Filter =

  domain: ( domain ) ->
    ({ conditions }) ->
      ( Match.Domain.condition conditions, domain ) ||
        ( Match.Domain.wildcard conditions )
    
  resource: ( resource ) ->
    ({ conditions }) ->
      ( Match.Resource.condition conditions, resource ) ||
        ( Match.Resource.wildcard conditions )
    
  method: ( method ) ->
    ({ conditions }) ->
      ( Match.Method.condition conditions, method ) ||
        ( Match.Method.wildcard conditions, method )

Map =

  schemes: ({ conditions }) ->
    conditions
      .filter ({ name }) -> name == "authorize"
      .map Obj.get "value"
      .reduce cat, []

match = ( rules, { domain, resource, method }) ->
  nullify do ->
    rules
      .filter Filter.domain domain
      .filter Filter.resource resource
      .filter Filter.method method
      .map Map.schemes
      .reduce cat, []

decorator = ({ policies }, handler ) ->
  ( request ) ->
    response = await handler request
    { resource, domain } = request
    if resource.name == "description"
      description = API.Description.from response.content
      policy = policies.map Obj.get "request"
      do ->
        for resource from description
          for method from resource
            for rules in policy
              if ( schemes = match rules, { domain, resource, method })?
                method.authorization = schemes
                return
      response.content = description.data
    response

export {
  decorator
}
