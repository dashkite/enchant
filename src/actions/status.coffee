import { register } from "./registry"

register "status", ( values, { response }) ->
  response.status in values
