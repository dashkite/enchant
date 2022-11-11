import { decorator } from "@dashkite/enchant-decorator"
import { Policies } from "./policies"

enchant = ( policies ) ->
  decorator policies, ( request ) ->
    await Policies.apply policies, request

export { enchant }