import log from "@dashkite/kaiko"
import { decorator } from "./decorator"
import { Policies } from "./policies"
import { set } from "./cache"

enchant = ({ policies, authorization }) ->
  decorator { authorization }, ( request ) ->
    log.debug enchant: { request }
    result = await Policies.apply policies, request
    log.debug enchant: response: result
    set request, result

import { register, lookup } from "./registry"

Registry = { register, lookup }

export { enchant, Registry }