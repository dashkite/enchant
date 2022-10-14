discover = ({ request, fetch }) ->
  { origin,  domain } = request
  response = await fetch 
    resource: { origin, domain, name: "description" }
    method: "get"
    # TODO maybe get rid of the need for this later?
    target: "/"
    headers: accept: [ "application/json" ]
  response.content

Resource =

  find: ( context ) ->
    { fetch, request } = context
    { origin, domain, target } = request
    api = await discover context
    if ( resource = decodeURLTarget api, target )?
      { domain, origin, resource... }
    else
      null

export {
  Resource
}