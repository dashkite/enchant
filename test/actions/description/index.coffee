import { test } from "@dashkite/amen"
import assert from "@dashkite/assert"
import { Actions } from "../../../src/actions"
import scenarios from "./scenarios"

description = do ->
  for scenario in scenarios
    { descriptions, response } = scenario
    if scenario.match
      test scenario.name, ->
        assert Actions["status description"] descriptions, { response }
    else        
      test scenario.name, ->
        assert !( Actions["status description"] descriptions, { response })

export { description }