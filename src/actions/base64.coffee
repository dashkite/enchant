import { convert } from "@dashkite/bake"
import { register } from "./registry"

register "base64", ( value ) ->
  convert from: "utf8", to: "base64", value