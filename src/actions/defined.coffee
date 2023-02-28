import { register } from "./registry"


register "defined", ( value ) ->
  value?
