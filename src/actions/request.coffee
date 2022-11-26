import { register } from "./registry"

register "request", ( value, context ) ->
  response = await Sky.fetch value
  response.content