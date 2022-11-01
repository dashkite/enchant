import * as Type from "@dashkite/joy/type"
import { generic } from "@dashkite/joy/generic"
import { register } from "./registry"

hasRequest = ( value ) -> value.request?.resource?
hasInclude = ( value ) -> value.include?
hasExclude = ( value ) -> value.exclude?

resource = ( handler ) ->
  ( target, { request: { resource }}) -> handler target, resource

handler = generic 
  name: "resource"
  description: "Enchant resource action"
  default: -> 
    throw new Error "enchant: unsupported target for resource action"

generic handler, Type.isArray, hasRequest,
  resource ( target, resource ) -> resource.name in target

generic handler, hasInclude, hasRequest,
  resource ( target, resource ) -> resource.name in target.include

generic handler, hasExclude, hasRequest,
  resource ( target, resource ) -> !( resource.name in target.exclude )

generic handler, Type.isString, hasRequest,
  resource ( target, resource ) -> resource.name == target

register "resource", handler