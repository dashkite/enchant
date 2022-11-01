import { test } from "@dashkite/amen"
import assert from "@dashkite/assert"
import { Actions } from "../../src/actions"

resource = [

  test "included", ->

    do ({ bindings, context } = {}) ->
      resource =
        include: [ "foo" ]
      context =
        request:
          resource:
            name: "foo"
      assert Actions.resource resource, context
  
]

export { resource }