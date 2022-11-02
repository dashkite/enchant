import { test } from "@dashkite/amen"
import assert from "@dashkite/assert"
import { Actions } from "../../../src/actions"
import scenarios from "./scenarios"

resource = do ->

  for scenario in scenarios

    test scenario.name, [

      test "match", ->
        do ({ resource, request } = scenario.match ) ->
          assert Actions.resource resource, { request }
      
      test "mismatch", ->
        do ({ resource, request } = scenario.mismatch ) ->
          assert !Actions.resource resource, { request }

    ]



export { resource }