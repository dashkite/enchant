import { register } from "./registry"

register "status", ( values, { response }) ->
  response.description in values
