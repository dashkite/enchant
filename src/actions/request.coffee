import { register } from "./registry"

register "request", ( value ) ->
  Sky.fetch value