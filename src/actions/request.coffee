import { register } from "./registry"
import * as Sublime from "@dashkite/maeve/sublime"

register "request", ( value, context ) ->
  value.authorization ?= context.request.authorization
  response = await Sky.fetch value
  if Sublime.Response.Status.ok response
    response.content
  else
    console.warn "enchant: request action non ok status", response
    undefined