import { register } from "./registry"

register "json", ( value ) ->
  JSON.stringify value