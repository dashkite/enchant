import { Response } from "@dashkite/maeve/sublime"
import { register } from "./registry"

register "headers", ( headers, { response } ) ->
  if response?
    Response.Headers.append response, headers
  response
