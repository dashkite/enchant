import { test } from "@dashkite/amen"
import assert from "@dashkite/assert"
import { Actions } from "../../../src/actions"
import scenarios from "./scenarios"

equal = do ->

  for scenario in scenarios
    { value, context } = scenario
    if scenario.equal
      test scenario.name, ->
        assert Actions.equal value, context
    else        
      test scenario.name, ->
        assert !( Actions.equal value, context )

export { equal }