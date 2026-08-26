import { register } from "./registry"

register "method", ( value, { request }) ->
  if Array.isArray value
    request.method in value
  else
    request.method == value