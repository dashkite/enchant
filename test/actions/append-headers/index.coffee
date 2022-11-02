import { test } from "@dashkite/amen"
import assert from "@dashkite/assert"
import { Actions } from "../../../src/actions"
import scenarios from "./scenarios"

appendHeaders = do ->

  for scenario in scenarios
    { headers, response } = scenario
    test scenario.name, ->
      actual = Actions[ "append headers" ] headers, { response }
      assert.deepEqual scenario.expect, actual
        

export { appendHeaders }