import { register } from "./registry"

register "forward", ( value, context ) ->
  if value?
    context.proxy ?= {}
    context.proxy.request = context.request
    context.request = value
  context.response = await Sky.fetch context.request
  context.response.content