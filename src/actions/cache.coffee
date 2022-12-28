import { Temporal } from "@js-temporal/polyfill"
import { register } from "./registry"
import * as Sublime from "@dashkite/maeve/sublime"

isCacheable = ( response ) ->
  switch response?.description
    when "ok", "created"
      response.content?
    else false

toDuration = ( expires ) ->
  Temporal.Duration.from expires
    .total
      unit: "second"
      relativeTo: Temporal.Now.plainDateTimeISO()

# TODO add etag? last-modified?
register "cache", ( cache, { response } ) ->
  if isCacheable response
    if cache.expires?
      Sublime.Response.Headers.append response, 
        "cache-control", "max-age=#{ toDuration cache.expires }"
    if cache.public
      Sublime.Response.Headers.append response,
        "cache-control", "public"
    if cache.immutable
      Sublime.Response.Headers.append response,
        "cache-control", "immutable"
