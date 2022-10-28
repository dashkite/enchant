import {
  response
} from "@dashkite/maeve/sublime"

import {
  Policies
  decorator
} from "./helpers"

enchant = ( policies ) ->
 decorator policies, ( request ) ->
      await Policies.apply policies, request
