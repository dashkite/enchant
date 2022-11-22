import { register } from "./registry"

register "forward", ( _, context ) ->
  context.response = await Sky.fetch context.request
  context.response.content