import { test } from "@dashkite/amen"
import assert from "@dashkite/assert"
import { Actions } from "../../../src/actions"
import scenarios from "./scenarios"

headers = do ->

  for scenario in scenarios
    { headers, response } = scenario
    test scenario.name, ->
      actual = Actions.headers headers, { response }
      assert.deepEqual scenario.expect, actual
        

export { headers }