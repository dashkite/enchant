import { generic } from "@dashkite/joy/generic"
import * as Type from "@dashkite/joy/type"
import * as Text from "@dashkite/joy/text"

import {
  command
  isCommand
} from "./helpers"

assign = ( result, object ) -> Object.assign result, object

parseAuthorizationFromHeader = ( header ) ->
  [ credential, parameters... ] = Text.split ",", Text.trim header
  [ scheme, credential ] = Text.split /\s+/, credential
  parameters = parameters
    .map (parameter) -> Text.split "=", parameter
    .map ([ key, value ]) -> 
      [ Text.trim key ]: Text.trim value
    .reduce assign, {}
  { scheme, credential, parameters }

parseAuthorizationFromRequest = ( request ) ->
  if ( header = request.headers?.authorization?[0] )?
    parseAuthorizationFromHeader header

Matchers =

  authorization: ( { request }, value ) ->
    request.authorization ?= parseAuthorizationFromRequest request
    value == request.authorization?.scheme

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