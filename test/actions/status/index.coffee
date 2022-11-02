import { test } from "@dashkite/amen"
import assert from "@dashkite/assert"
import { Actions } from "../../../src/actions"
import scenarios from "./scenarios"

status = do ->
  for scenario in scenarios
    { statuses, response } = scenario
    if scenario.match
      test scenario.name, ->
        assert Actions.status statuses, { response }
    else        
      test scenario.name, ->
        assert !( Actions.status statuses, { response })

export { status }