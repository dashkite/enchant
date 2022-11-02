import { register } from "./registry"

register "match", ( { name, value }, context ) ->
  new Regexp value
    .test context[ name ]
