import { register } from "./registry"

register "status description", ( values, { response }) ->
  response.description in values
