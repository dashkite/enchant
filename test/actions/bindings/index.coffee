import { test } from "@dashkite/amen"
import assert from "@dashkite/assert"
import { Actions } from "../../../src/actions"
import scenarios from "./scenarios"

bindings = do ->
  for scenario in scenarios
    { bindings, context } = scenario
    if scenario.match
      test scenario.name, ->
        assert Actions.bindings bindings, context
    else
      test scenario.name, ->
        assert !( Actions.bindings bindings, context )

export { bindings }