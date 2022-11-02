import { register } from "./registry"

register "method", ( value, { request }) ->
  request.method in value