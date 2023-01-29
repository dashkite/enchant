import { convert } from "@dashkite/bake"
import { register } from "./registry"

register "base36", ( value ) ->
  if value?
    convert from: "utf8", to: "base36", value