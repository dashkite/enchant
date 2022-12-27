import * as Type from "@dashkite/joy/type"
import * as Val from "@dashkite/joy/value"
import { register } from "./registry"
import { Expression } from "../expression"


register "bindings", ( target, context) ->
  { request } = context
  { resource } = request
  { bindings } = resource

  Object.entries target
    .every ([ key, value ]) ->
      if bindings[key]? && value?
        Val.equal bindings[ key ], value
      else
        false
