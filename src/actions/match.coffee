import { register } from "./registry"

register "match", ({ name, value }, context ) ->
  context[ name ]? &&
    new RegExp value
      .test context[ name ]
