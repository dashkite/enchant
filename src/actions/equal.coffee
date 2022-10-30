import { register } from "./registry"

register "equal", ( { name, value }, context ) ->
  new Regexp value
    .test context[ name ]