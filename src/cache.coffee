import { Response } from "@dashkite/maeve/sublime"
import { parse as CacheControlParse } from "cache-control-parser"
import * as Val from "@dashkite/joy/value"
import * as Arr from "@dashkite/joy/array"

cacheable = ( request ) ->
  request.url? && request.method == "get"

current = ( entry ) -> entry.expires >= Date.now()

get = ( request ) ->
  if ( entry = cache[ request.url ] )?
    # TODO this should be an array of candidates with a match function
    # ex: candidates.find match request
    # that way we can match on authorization header, ...
    console.log "enchant: cache hit", request.url, entry
    if current entry
      console.log "enchant: entry still current"
      Val.clone entry.response
    else
      console.log "enchant: entry expired, removing from cache"
      delete cache[ request.url ]
      undefined

getMaxAge = ( response ) ->
  if ( header = Response.Headers.get response, "cache-control" )?
    directive = CacheControlParse header
    directive[ "s-maxage" ] ? directive[ "max-age" ]

set = ( request, response ) ->
  console.log "enchant: attempting to cache response", response
  if ( maxAge = getMaxAge response )? && ( Response.Status.ok response )
    console.log "enchant: got max-age, caching"
    cache[ request.url ] =
      expires: Date.now() + ( maxAge * 1000 )
      response: Val.clone response
  response

cache = ( { value, context }, handler ) ->
  { request } = context
  console.log "enchant: cache check", request

  if cacheable request
    console.log "enchant: cacheable request"
    if ( response = get request )?
      context.response = response
      response.content
    else
      handler value, context
  else
    handler value, context

export { cache, set }