import assert from "@dashkite/assert"
import { test, success } from "@dashkite/amen"
import print from "@dashkite/amen-console"

import { getSecret } from "@dashkite/dolores/secrets"
import * as Runes from "@dashkite/runes"
import { expand } from "@dashkite/polaris"

import { confidential } from "panda-confidential"
Confidential = confidential()

import { Enchanter } from "../src"

import fooAPI from "./api/foo"
import guardianAPI from "./api/guardian"
import policies from "./policies"

enchanter = Enchanter.create()
enchanter.register policies
enchant = enchanter.enchant.bind enchanter

# TODO update tests to better emulate guardian fetch
fetch = ( request ) ->
  # TODO possibly switch back to target using helper 
  #      to derive target from resource?
  { resource } = request
  switch resource.name
    when "description"
      content: JSON.stringify fooAPI
    when "workspace"
      content: address: "acme"
    when "workspaces"
      content: [ { address: "acme" }, { address: "happycorp" } ]
    when "account"
      content: address: "alice"
    else
      throw new Error "oops that's not a pretend resource!"

handler = enchant fetch

authorization = policies[1]
  .policies
  .request[1]
  .context[1]
  .authorization[ "issue rune" ]
  .authorization

context = email: "dan@dashkite.com"

authorization = expand authorization, context

do ->

  secret = await getSecret "guardian"

  { rune, nonce } = await Runes.issue { authorization, secret }

  print await test "@dashkite/enchant",  [

    test "unauthorized request", ->
      response = await handler
        url: "https://foo.dashkite.io/workspace/acme"
        method: "get"
      assert.equal response.description == "unauthorized"
      assert.equal response.headers[ "www-authenticate" ][0], "email"
    
    test "authorized with rune", ->
      response = await handler
        url: "https://foo.dashkite.io/workspace/acme"
        method: "get"
        headers:
          authorization: [
            "rune #{ rune }, nonce=#{ nonce }"
          ]
      assert.equal response.content.address, "acme"

    test "wrong authorization with rune", ->
      response = await handler
        url: "https://foo.dashkite.io/workspace/evil"
        method: "get"
        headers:
          authorization: [
            "rune #{ rune }, nonce=#{ nonce }"
          ]
      assert.equal response.description, "unauthorized"
      assert.equal response.content, "enchant: Rune authorization did not match
        the given request for resource 
        [ https://foo.dashkite.io/workspace/evil ]
        and method [ get ]."

    test { description: "issue rune", wait: 10000 }, ->
      response = await handler
        url: "https://foo.dashkite.io/workspace/acme"
        method: "get"
        headers:
          authorization: [
            "email dan@dashkite.com"
          ]
      assert.equal response.description, "unauthorized"
      assert response.headers[ "www-authenticate"].startsWith "rune, nonce="
    
    test "authenticate", ->
      # WARNING this is copied from the source
      #         if that code changes, we should also change it here
      { EncryptionKeyPair, SharedKey, Message, encrypt } = Confidential
      keyPair = EncryptionKeyPair.from "base64",
        await getSecret "guardian-encryption-key-pair"
      key = SharedKey.create keyPair
      message = Message.from "utf8", rune
      ciphertext = ( await encrypt key, message ).to "base36"

      response = await do ({ rune, nonce, authorization, response } = {}) ->
        ephemeral = policies[1]
          .policies
          .request[1]
          .context[3]
          .ephemeral[ "issue rune" ]
          .authorization

        authorization = expand ephemeral, { ciphertext }
        { rune, nonce } = await Runes.issue { authorization, secret }

        # we now have the ciphertext for the durable rune and the
        # rune and nonce for the ephemeral rune (that we'll use to
        # authenticate), simulating what we would have extracted from
        # the magic link received via the email...
        handler
          url: "https://foo.dashkite.io/authenticate/#{ciphertext}"
          method: "get"
          headers:
            authorization: [
              "rune #{rune}, nonce=#{nonce}"
            ]

      assert.equal response.description, "ok"
      assert.equal response.content, rune


  ]