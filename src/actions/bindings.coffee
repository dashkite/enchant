import * as Type from "@dashkite/joy/type"
import { register } from "./registry"
import { Expression } from "../expression"


register "bindings", ( target, context) ->
  { request } = context
  { resource } = request
  { bindings } = resource
  
  Object.entries target
    .every ([ key, value ]) ->
      value = Expression.apply value, context
      if bindings[key]? && value?
        if Type.isArray value
          bindings[ key ] in value
        else
          bindings[ key ] == value
      else
        false
