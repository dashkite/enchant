import * as Type from "@dashkite/joy/type"
import * as Fn from "@dashkite/joy/function"
import { generic } from "@dashkite/joy/generic"
import * as Text from "@dashkite/joy/text"
import { Messages } from "@dashkite/messages"
import { Router } from "@pandastrike/router"
import * as Runes from "@dashkite/runes"
import { getSecret } from "@dashkite/dolores/secrets"
import { expand } from "@dashkite/polaris"
import { sendEmail } from "@dashkite/dolores/ses"

import { confidential } from "panda-confidential"
Confidential = confidential()

import {
  command
  isCommand
} from "./helpers"

import { match } from "./matchers"

import authenticate from "./authenticate"
import _messages from "./messages"

messages = Messages.create()
messages.add _messages
messages.prefix = "enchant"

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

parseAuthorizationFromRequest = ( request ) ->
  if ( header = request.headers?.authorization?[0] )?
    parseAuthorizationFromHeader header

Resolvers =

  "issue rune": ( context, { secret, authorization } ) ->
    Runes.issue {
      secret: ( await getSecret secret )
      authorization 
    }

  "encrypt rune": ( context, bindings ) ->
    { rune } = bindings
    { EncryptionKeyPair, SharedKey, Message, encrypt } = Confidential
    keyPair = EncryptionKeyPair.from "base64",
      await getSecret bindings["key pair"]
    key = SharedKey.create keyPair
    message = Message.from "utf8", rune
    ( await encrypt key, message ).to "base36"

  request: ( context, { resource } ) ->
    context.fetch await requestFromResource { resource, method: "get" }

resolve = generic name: "enchant[resolve]"

generic resolve, Type.isObject, Type.isString, ( context, template ) ->
  expand template, context

generic resolve, Type.isObject, Type.isObject, ( context, action ) ->
  resolve context, command action

generic resolve, Type.isObject, isCommand, ( context, { name, bindings } ) ->
  Resolvers[ name ] context, expand bindings, context

Actions =

  "email authentication": ( context,  { email, link } ) ->
    params = 
      source: "DashKite Authentication <authentication@dashkite.com>"
      template: "dashkite-development-authenticate"
      toAddresses: [email]
      templateData: authenticationLink: link

    await sendEmail params

  "rune authorization": ( context ) ->
    { fetch, request } = context
    { scheme, credential, parameters } = request.authorization
    { nonce } = parameters
    if scheme == "rune"
      secret = await getSecret "guardian"
      if Runes.verify { rune: credential, nonce, secret }
        [ authorization ] = Runes.decode credential
        if request = await Runes.match { context..., authorization }
          context.response = fetch request
        else
          context.response = unauthorized "request disallowed", context
      else
        context.response = unauthorized "verification failed", { request }
    else
      context.response = unauthorized "wrong authorization", { request, scheme }

  response: ( context, response ) -> context.response = response

execute = generic name: "enchant[execute]"

generic execute, Type.isObject, Type.isString, ( context, name ) ->
  execute context, { name, bindings: {} }

generic execute, Type.isObject, Type.isObject, ( context, action ) ->
  execute context, command action

generic execute, Type.isObject, isCommand, ( context, { name, bindings } ) ->
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
        request.authorization = parseAuthorizationFromRequest request
        for policy in policies.request
          context = { request, fetch: f }
          if match context, policy.conditions
            if policy.context?
              for resolver in policy.context
                for key, _resolver of resolver
                  context[ key ] = await resolve context, _resolver
            for action in policy.actions
              await execute context, expand action, context
            break if context.response? || context.forward

      # unless context.response?

      #   # if we got there without throwing, that means all the policices
      #   # were satisfied so we can forward the request
      #   context.response = await f request

      # # TODO apply the response policies
      # # finally, return the response
      context.response

export  { Enchanter }