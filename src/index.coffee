import { decorator } from "./decorator"
import { Policies } from "./policies"
import { set } from "./cache"

enchant = ({ policies, authorization }) ->
  decorator { authorization }, ( request ) ->
    result = await Policies.apply policies, request
    set request, result

import { register, lookup } from "./registry"

Registry = { register, lookup }

export { enchant, Registry }