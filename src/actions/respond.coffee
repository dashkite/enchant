import { register } from "./registry"

register "respond", ( value, context ) ->
  context.response = value