import {
  response
} from "@dashkite/maeve/sublime"

import {
  Policies
  decorate
} from "./helpers"

enchant = ( policies ) ->
  ( request ) ->
    decorate policies,
      await Policies.apply policies, request
