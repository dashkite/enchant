import {
  response
} from "@dashkite/maeve/sublime"

import { Policies } from "./policies"
import { decorator } from "./decorator"

enchant = ( policies ) ->
 decorator policies, ( request ) ->
      await Policies.apply policies, request
