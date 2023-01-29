import { register } from "./registry"

register "json", ( value ) ->
  if value?
    JSON.stringify value