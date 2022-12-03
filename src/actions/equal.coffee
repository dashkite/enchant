import { register } from "./registry"

register "equal", ( [lhs, rhs] ) ->
  lhs == rhs