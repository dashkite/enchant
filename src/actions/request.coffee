import { register } from "./registry"

register "request", ( value ) ->
  response = await Sky.fetch value
  # TODO check response status for okay
  response.content