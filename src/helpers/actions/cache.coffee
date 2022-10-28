import { Temporal } from "@js-temporal/polyfill"
import { register } from "./registry"

isCacheable = ( response ) ->
  switch response?.description
    when "ok", "created"
      response.content?
    else false

# TODO add etag? last-modified?
register "cache", ( cache, { response } ) ->
  if isCacheable response
    if cache.expires?
      Sublime.Response.appendHeader response, 
        "cache-control", "max-age=#{ toDuration cache.expires }"
    if cache.public
      Sublime.Response.appendHeader response,
        "cache-control", "public"
    if cache.immutable
      Sublime.Response.appendHeader response,
        "cache-control", "immutable"
