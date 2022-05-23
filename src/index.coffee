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
import URITemplate from "uri-template.js"

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

  "authenticate": ( context, bindings ) ->
    { ciphertext } = context.request.resource.bindings
    { Envelope, EncryptionKeyPair, SharedKey, Message, decrypt } = Confidential
    envelope = Envelope.from "base36", ciphertext
    keyPair = EncryptionKeyPair.from "base64",
      await getSecret bindings["key pair"]
    key = SharedKey.create keyPair
    message = decrypt key, envelope
    rune = message.to "utf8"
    context.response =
      description: "ok"
      content: rune

  "rune authorization": ( context ) ->
    { fetch, request } = context
    { scheme, credential, parameters } = request.authorization
    { nonce } = parameters
    if scheme == "rune"
      secret = await getSecret "guardian"
      if Runes.verify { rune: credential, nonce, secret }
        [ authorization ] = Runes.decode credential
        if request = await Runes.match { context..., authorization }
          context.request = request
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

discover = ({ fetch, origin }) ->
  response = await fetch 
    resource: { origin, name: "description" }
    method: "get"
    # TODO maybe get rid of the need for this later?
    target: "/"
    headers: accept: "application/json"
  JSON.parse response.content

Request =
  origin: ( request ) ->
    request._url ?= new URL request.url
    request._url.origin

  target: ( request ) ->
    url = ( request._url ?= new URL request.url )
    url.pathname + url.search

Resource =
  find: do ( cache = {}) ->
    ( context ) ->
      { fetch, request } = context
      origin = Request.origin request
      target = Request.target request
      api = ( cache[ origin ] ?= await discover { fetch, origin } )
      for name, resource of api.resources
        bindings = URITemplate.extract resource.template, target
        if ( target == URITemplate.expand resource.template, bindings )
          return { origin, name, bindings }
      null

Rules =
  find: (resource, rules) ->
    rules.find ( rule ) ->
      rule.resources.find ( candidate ) ->
        if candidate.include?
          ( resource.origin == candidate.origin ) &&  
            ( resource.name in candidate.include )
        else if candidate.exclude?
          ( resource.origin == candidate.origin ) &&  
            !( resource.name in candidate.exclude )
        else
          throw failure "bad rule definition", rule

class Enchanter

  @create: -> new @

  register: ( @rules ) ->

  enchant: (fetch) ->

    rules = @rules
    
    (request) ->
      if ( resource = await Resource.find { request, fetch } )?
        request.resource = resource
        if ( rule = Rules.find resource, rules )?
          request.authorization = parseAuthorizationFromRequest request
          for policy in rule.policies.request
            context = { request, fetch }
            if match context, policy.conditions
              if policy.context?
                for resolver in policy.context
                  for key, _resolver of resolver
                    context[ key ] = await resolve context, _resolver
              for action in policy.actions
                await execute context, expand action, context
                break if context.response?
              unless context.response?
                context.response = await fetch context.request
              break
          # # TODO apply the response policies
          # # finally, return the response
          context.response
        else
          # TODO should this be the default for a non-matched rule?
          #      rationale is that we already exclude public resources
          #      in the rule specification
          fetch request
      else
        description: "not found"

export  { Enchanter }