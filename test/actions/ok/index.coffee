import { test } from "@dashkite/amen"
import assert from "@dashkite/assert"
import { Actions } from "../../../src/actions"
import scenarios from "./scenarios"

ok = do ->
  for scenario in scenarios
    { response } = scenario
    if scenario.match
      test scenario.name, ->
        assert Actions.ok null, { response }
    else        
      test scenario.name, ->
        assert !( Actions.ok null, { response })

export { ok }