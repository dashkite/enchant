import { Authorization } from "@dashkite/http-headers"
import { convert } from "@dashkite/bake"
import { register } from "./registry"

  
json64 = ( value ) ->
  convert
    from: "utf8"
    to: "base64"
    JSON.stringify value

register "format authorization", ({ scheme, token, parameters }) ->
  if scheme?
    if token?
      if scheme == "credentials"
        token = json64 token
      Authorization.format { scheme, token }
    else if parameters?
      Authorization.format { scheme, parameters }