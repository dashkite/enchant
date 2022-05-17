import * as Type from "@dashkite/joy/type"
import { generic } from "@dashkite/joy/generic"

import {
  command
  isCommand
} from "./helpers"

Matchers =

  authorization: ( context, value ) ->
    value == context.request.authorization?.scheme

  bindings: ( context, value ) ->
    for key, _value of value
      if context[ key ] == _value
        continue
      else
        return false
    true

match = generic name: "enchant[match]"

generic match, Type.isObject, Type.isUndefined, ( context, conditions ) ->
  true

generic match, Type.isObject, Type.isObject, ( context, action ) ->
  match context, command action

generic match, Type.isObject, isCommand, ( context, { name, bindings } ) ->
  Matchers[ name ] context, bindings

generic match, Type.isObject, Type.isArray, ( context, conditions ) ->
  conditions.every ( condition ) -> match context, condition

export { match }