import * as Val from "@dashkite/joy/value"
import { register } from "./registry"

register "equal", ([ lhs, rhs ]) ->
  Val.equal lhs, rhs
