import log from "@dashkite/kaiko"
import { decorator } from "./decorator"
import { Policies } from "./policies"
import { initialize, set } from "./cache"

enchant = ({ policies, authorization, cache }) ->
  initialize cache
  decorator { authorization }, ( request ) ->
    log.context "enchant", ->
      log.debug { request }
      result = await Policies.apply policies, request
      log.debug response: result
      set request, result

import { register, lookup } from "./registry"

Registry = { register, lookup }

export { enchant, Registry }