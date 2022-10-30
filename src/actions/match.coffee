import { register } from "./registry"

register "match", ( { name, value }, context ) ->
  context[ name ] == value