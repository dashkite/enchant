import { test } from "@dashkite/amen"
import assert from "@dashkite/assert"
import { Actions } from "../../../src/actions"
import scenarios from "./scenarios"

match = do ->

  for scenario in scenarios
    { value } = scenario
    if scenario.match
      test scenario.name, ->
        assert Actions.match value
    else        
      test scenario.name, ->
        assert !( Actions.match value )

export { match }