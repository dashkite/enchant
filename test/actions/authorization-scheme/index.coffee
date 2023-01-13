import { test } from "@dashkite/amen"
import assert from "@dashkite/assert"
import { Actions } from "../../../src/actions"
import scenarios from "./scenarios"

authorizationScheme = do ->
  for scenario in scenarios
    { scheme, request } = scenario
    if scenario.match
      test scenario.name, ->
        assert Actions["authorization scheme"] scheme, { request }
    else        
      test scenario.name, ->
        assert !( Actions["authorization scheme"] scheme, { request })

export { authorizationScheme }