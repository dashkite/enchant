import { Response } from "@dashkite/maeve/sublime"
import { register } from "./registry"

register "cors", (_, { request, response }) ->
  if request? && response?
    headers = 
      "access-control-expose-headers": "credentials"
    if request.headers?.origin?
      headers[ "access-control-allow-origin" ] = request.headers.origin[0]
    else if request.proxy?.request.headers?.origin?
      headers[ "access-control-allow-origin" ] = request.proxy.request.headers.origin[0]
    Response.Headers.set response, headers
