import * as Type from "@dashkite/joy/type"
import { generic } from "@dashkite/joy/generic"
import { register } from "./registry"

# predicates
hasRequest = ( value ) -> value.request?.domain?
hasInclude = ( value ) -> value.include?
hasExclude = ( value ) -> value.exclude?

# destructuring combinator
domain = ( handler ) ->
  ( target, { request: { domain }}) -> handler target, domain

handler = generic name: "domain"

generic handler, hasExclude, hasRequest,
  domain ( target, domain ) -> !( domain in target.exclude )

generic handler, hasInclude, hasRequest,
  domain ( target, domain ) -> domain in target.include

generic handler, Type.isArray, hasRequest,
  domain ( target, domain ) -> domain in target

generic handler, Type.isString, hasRequest,
  domain ( target, domain ) -> domain == target

register "domain", handler