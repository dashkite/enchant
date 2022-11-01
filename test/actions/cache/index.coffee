import { test } from "@dashkite/amen"
import assert from "@dashkite/assert"
import { Actions } from "../../../src/actions"
import scenarios from "./scenarios"

cache = [

  test "cache", do ->
    for scenario in scenarios
      test scenario.name, ->
        { cache, response } = scenario
        Actions.cache cache, { response }
        assert.deepEqual response.headers, scenario.expect    
]

export { cache }