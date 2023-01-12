import { register } from "./registry"
import * as Sublime from "@dashkite/maeve/sublime"
import { invalidate } from "../cache"

register "invalidate", ( value, context ) ->
  invalidate value, context
