import { Response } from "@dashkite/maeve/sublime"
import { parse as CacheControlParse } from "cache-control-parser"
import * as Val from "@dashkite/joy/value"
import * as Arr from "@dashkite/joy/array"
import * as URLCodex from "@dashkite/url-codex"
import * as Parsers from "@dashkite/url-codex/parsers"
import { invalidatePaths } from "@dashkite/dolores/cloudfront"
import * as Dracarys from "@dashkite/dracarys"
import configuration from "./configuration"

Cache = Dracarys.Client.create configuration.dracarys

cacheable = ( request ) ->
  request.url? && request.method == "get"

normalizeRequest = ( request ) ->
  { domain, resource } = request
  { domain, resource }

get = ( request ) ->
  if ( entry = await Cache.get ( normalizeRequest request ) )?
    # console.log "enchant: cache hit", request.url, entry
    Val.clone entry
  else
    undefined

cache = ( { value, context }, handler ) ->
  { request } = context
  # console.log "enchant: cache check", request
  if cacheable request
    # console.log "enchant: cacheable request"
    if ( response = await get request )?
      Response.Headers.append response, "guardian-cache": "hit"
      Response.Headers.remove response, "credentials"
      context.response = response
      response.content
    else
      handler value, context
  else
    handler value, context

getMaxAge = ( response ) ->
  if ( header = Response.Headers.get response, "cache-control" )?
    directive = CacheControlParse header
    directive[ "s-maxage" ] ? directive[ "max-age" ]

set = ( request, response ) ->
  # console.log "enchant: attempting to cache response", response
  if cacheable request
    if ( maxAge = getMaxAge response )? && ( Response.Status.ok response )
      if ( Response.Headers.get response, "guardian-cache" ) != "hit"
        # console.log "enchant: got max-age, caching"
        await Cache.put ( normalizeRequest request ), ( Val.clone response )
  response

invalidateGuardian = ( value ) ->
  for request in value
    # console.log "enchant: invalidating entry from guardian cache", request
    await Cache.delete ( normalizeRequest request )
    undefined

invalidate = ( value, context ) ->
  invalidateGuardian value

export { cache, set, invalidate }