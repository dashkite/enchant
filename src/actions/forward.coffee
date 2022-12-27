import { syncInvokeLambda } from "@dashkite/dolores/lambda"
import { convert } from "@dashkite/bake"
import { register } from "./registry"
import { cache } from "../cache"

forwardLambda = ( request ) ->
  { Payload, StatusCode } = await syncInvokeLambda request.lambda, request
  if 200 <= StatusCode < 300
    JSON.parse convert to: "utf8", from: "bytes", Payload
  else
    console.error "Lambda invocation failure"
    status: 502

forward = ->
  ( value, context ) -> 
    if value?
      context.proxy ?= {}
      context.proxy.request = context.request
      context.request = value
      context.response = await Sky.fetch context.request
    else
      context.response = await forwardLambda context.request
      context.response.content

register "forward", ( value, context ) ->
  cache { value, context }, forward()