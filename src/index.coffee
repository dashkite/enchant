import { decorator } from "./decorator"
import { Policies } from "./policies"

enchant = ( policies ) ->
  decorator policies, ( request ) ->
    await Policies.apply policies, request

import { register, lookup } from "./registry"

Registry = { register, lookup }

export { enchant, Registry }