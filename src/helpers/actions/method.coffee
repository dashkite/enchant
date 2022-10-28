import { register } from "./registry"

register "resource", ( value, { request } ) ->
  request.method == value