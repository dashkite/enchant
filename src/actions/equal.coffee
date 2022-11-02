import { register } from "./registry"

register "equal", ({ name, value }, context ) ->
  context[ name ] == value