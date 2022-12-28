import { test } from "@dashkite/amen"
import assert from "@dashkite/assert"
import { Actions } from "../../../src/actions"
import scenarios from "./scenarios"

equal = do ->

  for scenario in scenarios
    { value } = scenario
    if scenario.equal
      test scenario.name, ->
        assert Actions.equal value
    else        
      test scenario.name, ->
        assert !( Actions.equal value )

export { equal }