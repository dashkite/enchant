import assert from "@dashkite/assert"
import { test, success } from "@dashkite/amen"
import print from "@dashkite/amen-console"

import { getSecret } from "@dashkite/dolores/secrets"
import * as Runes from "@dashkite/runes"

import fetch from "node-fetch"
globalThis.fetch = fetch

import { Enchanter } from "../src"
import policies from "./policies"

enchanter = Enchanter.create()
enchanter.register policies
enchant = enchanter.enchant.bind enchanter

handler = enchant ( request ) -> console.log "request forwarded", request


authorization =
  origin: "https://workspaces.dashkite.io"
  expires: ( new Date ).toISOString()
  grants: [
      resources: [ "account-workspaces" ]
      bindings: account: "acme"
      methods: [ "get" ]
  ]

do ->

  secret = await getSecret "guardian"

  { rune, nonce } = await Runes.issue { authorization, secret }

  print await test "@dashkite/enchant",  [

    test "unauthorized request", ->
      response = await handler
        url: "https://workspaces.dashkite.io/accounts/acme/workspaces"
        method: "get"

      assert.equal response.description == "unauthorized"
      assert.equal response. headers[ "www-authenticate" ][0], "email"
    
    test "authorized with rune", ->
      response = await handler
        url: "https://workspaces.dashkite.io/accounts/acme/workspaces"
        method: "get"
        headers:
          authorization: [
            "rune #{ rune }, nonce=#{ nonce }"
          ]
      console.log response



  ]