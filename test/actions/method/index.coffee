import { test } from "@dashkite/amen"
import assert from "@dashkite/assert"
import { Actions } from "../../../src/actions"
import scenarios from "./scenarios"

method = do ->
  for scenario in scenarios
    { methods, request } = scenario
    if scenario.match
      test scenario.name, ->
        assert Actions.method methods, { request }
    else        
      test scenario.name, ->
        assert !( Actions.method methods, { request })

export { method }