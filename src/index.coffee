import * as Type from "@dashkite/joy/type"
import * as Fn from "@dashkite/joy/function"
import { generic } from "@dashkite/joy/generic"
import * as Text from "@dashkite/joy/text"
import { Messages } from "@dashkite/messages"
import * as Runes from "@dashkite/runes"
import { getSecret } from "@dashkite/dolores/secrets"
import { sendEmail } from "@dashkite/dolores/ses"
import { getObject } from "@dashkite/dolores/bucket"
import * as Graphene from "@dashkite/graphene-lambda-client"
import { MediaType } from "@dashkite/media-type"

import { expand } from "@dashkite/polaris"
import * as URLCodex from "@dashkite/url-codex"

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

grapheneClient = Graphene.Client.create "graphene-beta-development-api"

unauthorized = ( code, context ) ->
  # TODO add www-authenticate header?
  description: "unauthorized"
  content: messages.message code, context

assign = ( result, object ) -> Object.assign result, object

generateAddress = ->
  Confidential.convert from: "bytes", to: "base36", await Confidential.randomBytes 8

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

  "hash ciphertext": ( context, bindings ) ->
    { ciphertext } = bindings
    { Message, hash, convert } = Confidential
    cipher_message = Message.from "base36", ciphertext
    ( hash cipher_message ).to "base36"

  request: ( context, { resource } ) ->
    await context.fetch await requestFromResource { resource, method: "get" }

resolve = generic name: "enchant[resolve]"

generic resolve, Type.isObject, Type.isString, ( context, template ) ->
  expand template, context

generic resolve, Type.isObject, Type.isObject, ( context, action ) ->
  resolve context, command action

generic resolve, Type.isObject, isCommand, ( context, { name, bindings } ) ->
  Resolvers[ name ] context, expand bindings, context

Actions =

  "load bundle": ( context, { database } ) ->
    { code } = context.request.resource.bindings
    db = await grapheneClient.db.get database
    collection = await db.collections.get "bundles"
    if ( bundle = await collection.entries.get code )?
      context.response = 
        description: "ok"
        content: bundle.content
        headers:
          "content-type": [ "application/json"]
    else
      context.response = 
        description: "not found"

  "email authentication": ( context,  { database, email, ciphertext, hash, ephemeral } ) ->
    address = await generateAddress()
    item = { ciphertext, hash, ephemeral }
    
    #TODO Expire this item in graphene
    db = await grapheneClient.db.get database
    collection = await db.collections.get "bundles"
    await collection.entries.put address, item
    
    link = "https://workspaces.dashkite.com/authenticate/#{address}"
    params = 
      source: "DashKite Authentication <authentication@dashkite.com>"
      template: "dashkite-development-authenticate"
      toAddresses: [email]
      templateData: authenticationLink: link

    try 
      await sendEmail params
    catch
      console.log "SEND EMAIL ERROR"
      context.response =
        description: "bad request"
        content: "send email failed"

  "authenticate": ( context, bindings ) ->
    ciphertext = context.request.content
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
      headers:
        "content-type": [ "text/plain"]

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

  "load media": ( context, { database, fallback } ) ->
    { request } = context
    { resource, target } = request
    { domain } = resource
    # TODO generate these based on accept?
    # TODO use configuration to determine

    # drop the leading /
    # TODO we could simply require the / in the key by convention?
    target = target[1..]
    candidates = []

    if target == "" then candidates.push "index.html"
    else if target.endsWith "/" then candidates.push target[...-1]
    else if !( /\.\w+$/.test target )
      candidates.push "#{target}.html"
      candidates.push "#{target}/index.html"
    else
      candidates.push target

    if fallback? && !( fallback in candidates )
      candidates.push fallback

    for key in candidates
      mediaType = MediaType.fromPath key
      item = switch MediaType.category mediaType
        when "text", "json"
          encoding = "text"
          db = await grapheneClient.db.get database
          collection = await db.collections.get domain
          await collection.entries.get key
        when "binary"
          encoding = "base64"
          await getObject domain, key
      if item?
        context.response =
          description: "ok"
          content: item.content
          encoding: encoding
          headers:
            "content-type": [ MediaType.format mediaType ]
        break
    context.response ?= description: "not found"

execute = generic name: "enchant[execute]"

generic execute, Type.isObject, Type.isString, ( context, name ) ->
  execute context, { name, bindings: {} }

generic execute, Type.isObject, Type.isObject, ( context, action ) ->
  execute context, command action

generic execute, Type.isObject, isCommand, ( context, { name, bindings } ) ->
  Actions[ name ] context, bindings

discover = ({ fetch, origin, domain }) ->
  response = await fetch 
    resource: { origin, domain, name: "description" }
    method: "get"
    # TODO maybe get rid of the need for this later?
    target: "/"
    headers: accept: "application/json"
  response.content

Request =
  origin: ( request ) ->
    request._url ?= new URL request.url
    request._url.origin

  domain: ( request ) ->
    request._url ?= new URL request.url
    request._url.hostname

  target: ( request ) ->
    url = ( request._url ?= new URL request.url )
    url.pathname + url.search

Resource =
  find: ( context ) ->
    { fetch, request } = context
    origin = Request.origin request
    target = Request.target request
    # so we have it later...
    # TODO maybe normalize the request beforehand?
    domain = Request.domain request
    api = await discover { fetch, domain, origin }
    for name, resource of api.resources when resource.template?
      # TODO template expansion of {/path*} should return [] for /, not null
      #      for now, we allow an array of templates, which might be a reasonable
      #      thing to do in any event...
      { template } = resource
      templates = if Type.isArray template then template else [ template ]
      for template in templates
        if ( bindings = URLCodex.match template, target )?
          return { domain, origin, name, bindings }
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

cors = (f) ->
  ( request ) -> 
    response = await f request
    response.headers ?= {}
    #TODO We will need to expand this list. Should we wilcard it?
    Object.assign response.headers,
      "access-control-allow-origin": [ "*" ]
      "access-control-allow-methods": [ "*" ]
      "access-control-allow-headers": [ "*" ]
      "access-control-expose-headers": [ "*" ]
    response

decorateMethods = ( policies, methods ) ->
  for key, method of methods
    signature = ( method.signatures.request ?= {} )
    for policy in policies
      if policy.conditions?
        for condition in policy.conditions when condition.authorization?
          signature.authorization ?= []
          if !( condition.authorization in signature.authorization )
            signature.authorization.push condition.authorization

decorateAPIDescription = ( rules, request, response ) ->
  { origin } = request.resource
  description = response.content
  for rule in rules
    for resource in rule.resources
      if resource.origin == origin
        if resource.include? 
          for name in resource.include
            decorateMethods rule.policies.request, description.resources[name].methods
        else if resource.exclude?
          for name of description.resources
            if !( name in resource.exclude )
              decorateMethods rule.policies.request, description.resources[name].methods
        else
          throw failure "bad rule definition", rule
  response

decorate = ( rules, f ) ->
  ( request ) -> 
    response = await f request
    if request.resource?.name == "description"
      decorateAPIDescription rules, request, response
    else
      response

enchant = ( rules, fetch ) ->

  decorate rules, cors (request) ->
    if ( resource = await Resource.find { request, fetch } )?
      request.resource = resource
      if request.method == "options"
        description: "no content"
      else if ( rule = Rules.find resource, rules )?
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
          else
            context.response = description: "bad request"
        # TODO apply the response policies
        # finally, return the response
        context.response
      else
        # TODO should this be the default for a non-matched rule?
        #      rationale is that we already exclude public resources
        #      in the rule specification
        await fetch request
    else
      description: "not found"

export { enchant }