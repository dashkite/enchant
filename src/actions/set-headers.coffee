import { Response } from "@dashkite/maeve/sublime"
import { register } from "./registry"

register "set headers", ( headers, { response } ) ->
  if response?
    Response.Headers.set response, headers
  response
