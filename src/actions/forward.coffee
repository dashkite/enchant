import { syncInvokeLambda } from "@dashkite/dolores/lambda"
import { convert } from "@dashkite/bake"
import { register } from "./registry"
import { cache } from "../cache"

forwardLambda = ( request ) ->
  start = Date.now()
  # console.log "FORWARD LAMBDA INVOKE"
  { Payload, StatusCode } = await syncInvokeLambda request.lambda, request
  # console.log "FORWARD LAMBDA DURATION", Date.now() - start, "ms"
  if 200 <= StatusCode < 300
    JSON.parse convert to: "utf8", from: "bytes", Payload
  else
    console.error "Lambda invocation failure"
    status: 502

forward = ->
  ( value, context ) -> 
    if value?
      context.response = await Sky.fetch context.request
    else
      context.response = await forwardLambda context.request
      # console.log "FORWARD RESPONSE", context.response
      context.response.content

register "forward", ( value, context ) ->
  if value?
    context.proxy ?= {}
    context.proxy.request = context.request
    context.request = value
  cache { value, context }, forward()