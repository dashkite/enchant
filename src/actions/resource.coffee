import * as Type from "@dashkite/joy/type"
import { generic } from "@dashkite/joy/generic"
import { register } from "./registry"

# predicates
hasRequest = ( value ) -> value.request?.resource?
hasInclude = ( value ) -> value.include?
hasExclude = ( value ) -> value.exclude?

# destructuring combinator
resource = ( handler ) ->
  ( target, { request: { resource }}) -> handler target, resource

handler = generic name: "resource"

generic handler, hasExclude, hasRequest,
  resource ( target, resource ) -> !( resource.name in target.exclude )

generic handler, hasInclude, hasRequest,
  resource ( target, resource ) -> resource.name in target.include

generic handler, Type.isArray, hasRequest,
  resource ( target, resource ) -> resource.name in target

generic handler, Type.isString, hasRequest,
  resource ( target, resource ) -> resource.name == target

register "resource", handler