import assert from "@dashkite/assert"
import { test, success } from "@dashkite/amen"
import print from "@dashkite/amen-console"

import { getSecret } from "@dashkite/dolores/secrets"
import * as Runes from "@dashkite/runes"
import { expand } from "@dashkite/polaris"

import { Enchanter } from "../src"

import fooAPI from "./api/foo"
import guardianAPI from "./api/guardian"
import policies from "./policies"

enchanter = Enchanter.create()
enchanter.register policies
enchant = enchanter.enchant.bind enchanter

fetch = ( request ) ->
  # TODO possibly switch back to target using helper 
  #      to derive target from resource?
  { resource } = request
  switch resource.name
    when "description"
      fooAPI
    when "workspace"
      address: "acme"
    when "workspaces"
      [ { address: "acme" }, { address: "happycorp" } ]
    when "account"
      address: "alice"
    else
      throw new Error "oops that's not a pretend resource!"

handler = enchant fetch

authorization = policies[1]
  .policies
  .request[1]
  .context[1]
  .authorization[ "issue rune" ]
  .authorization

context = email: "alice@acme.org"

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
      assert.equal response. headers[ "www-authenticate" ][0], "email"
    
    test "authorized with rune", ->
      response = await handler
        url: "https://foo.dashkite.io/workspace/acme"
        method: "get"
        headers:
          authorization: [
            "rune #{ rune }, nonce=#{ nonce }"
          ]
      assert.equal response.address, "acme"

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

    test "issue rune", ->
      response = await handler
        url: "https://foo.dashkite.io/workspace/acme"
        method: "get"
        headers:
          authorization: [
            "email alice@acme.org"
          ]
      console.log response

  ]