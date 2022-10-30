import { register } from "./registry"

register "status", ( value, { response } ) ->
  response?.status == value
