import * as Type from "@dashkite/joy/type"
import * as Fn from "@dashkite/joy/function"
import { generic } from "@dashkite/joy/generic"
import * as Text from "@dashkite/joy/text"
import { Messages } from "@dashkite/messages"
import { Router } from "@pandastrike/router"
import * as Parse from "@dashkite/parse"
import * as Runes from "@dashkite/runes"
import { getSecret } from "@dashkite/dolores/secrets"
import _messages from "./messages"

messages = Messages.create()
messages.add _messages
messages.prefix = "enchant"

parseAuthorizationFromHeader = Parse

unauthorized = ( code, context ) ->
  # TODO add www-authenticate header?
  description: "unauthorized"
  content: messages.message code, context

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

# parseAuthorizationFromHeader = Parse.parser Parse.pipe [
#   Parse.all [
#     Parse.word
#     Parse.skip Parse.ws
#     Parse.re /^[^,]+/
#     Parse.list ( Parse.text "," ), Parse.all [
#       Parse.word
#       Parse.text "="
#       Parse.word
#     ]
#   ]
# ]

parseAuthorizationFromRequest = ( request ) ->
  if ( header = request.headers?.authorization?[0] )?
    parseAuthorizationFromHeader header

Matchers =
  authorization: ( context, value ) ->
    value == context.authorization?.scheme
  bindings: ( context, value ) ->
    for key, _value of value
      if context[ key ] == _value
        continue
      else
        return false
    true

match = ( context, policy ) ->
  if policy.condition?
    for key, value of policy.condition
      if !( Matchers[ key ] context, value )
        return false
    true
  else
    true

Resolvers =
  request: ( context, resource ) ->
    context.forward await requestFromResource { resource, method: "get" }

Actions =

  "issue rune": (context, { rune }) ->

  "rune authorization": ( context ) ->
    { request, authorization } = context
    { scheme, credential, parameters } = authorization
    { nonce } = parameters
    if scheme == "rune"
      secret = await getSecret "guardian"
      if Runes.verify { rune: credential, nonce, secret }
        [ authorization ] = Runes.decode credential
        if await Runes.match { request, authorization }
          context.forward = true
        else
          context.response = unauthorized "request disallowed", { request }
      else
        context.response = unauthorized "verification failed", { request }
    else
      context.response = unauthorized "wrong authorization", { request, scheme }

  response: ( context, response ) -> context.response = response

resolve = generic name: "enchant[resolve]"

generic resolve, Type.isObject, Type.isString, ( context, template ) ->
  expand template, context

generic resolve, Type.isObject, Type.isObject, ( context, { name, bindings } ) ->
  Resolvers[ name ] context, bindings

execute = generic name: "enchant[execute]"

generic execute, Type.isObject, Type.isObject, ( context, { name, bindings } ) ->
  Actions[ name ] context, bindings

class Enchanter

  @create: -> new @

  constructor: -> 
    @router = Router.create()

  register: ( policies ) ->
    for policy in policies
      @router.add 
        template: policy.resources
        data: policy

  enchant: (f) ->

    router = @router
    
    (request) ->
      if ( _match = router.match request.url )?
        { policies } = _match.data
        authorization = parseAuthorizationFromRequest request
        for policy in policies.request
          context = { request, forward: f, authorization, authorized: false }
          if match context, policy
            for key, resolver of policy.context
              context[ key ] = await resolve context, resolver
            for action in policy.actions
              await execute context, action
            break if context.response? || context.forward

      # unless context.response?

      #   # if we got there without throwing, that means all the policices
      #   # were satisfied so we can forward the request
      #   context.response = await f request

      # # TODO apply the response policies
      # # finally, return the response
      context.response

export  { Enchanter }