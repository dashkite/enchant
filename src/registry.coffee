import * as Type from "@dashkite/joy/type"
import { generic } from "@dashkite/joy/generic"

isAny = -> true

registry = {}

register = generic name: "register"

generic register, Type.isArray, isAny, ( keys, value ) ->
  current = registry
  [ scopes..., key ] = keys
  for scope in scopes
    current = ( current[ scope ] ?= {} )
  current[ key ] = value

generic register, Type.isString, isAny, ( key, value ) ->
  registry[ key ] = value

lookup = generic name: "lookup"

generic lookup, Type.isArray, ( keys ) ->
  current = registry
  [ scopes..., key ] = keys
  for scope in scopes
    current = current[ scope ]
  current[ key ]

generic lookup, Type.isString, ( key ) ->
  registry[ key ]

export {
  registry
  register
  lookup
}