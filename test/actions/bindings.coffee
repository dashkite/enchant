import { test } from "@dashkite/amen"
import assert from "@dashkite/assert"
import { Actions } from "../../src/actions"

bindings = [

  test "exact match", ->
    do ({ bindings, context } = {}) ->
      bindings =
        foo: "abc"
        bar: "def"
      context =
        request:
          resource:
            bindings:
              foo: "abc"
              bar: "def"
      assert Actions.bindings bindings, context

  test "mismatch", ->
    do ({ bindings, context } = {}) ->
      bindings =
        foo: "abc"
        bar: "ghi"
      context =
        request:
          resource:
            bindings:
              foo: "abc"
              bar: "def"
      assert !Actions.bindings bindings, context

  test "subset", ->
    do ({ bindings, context } = {}) ->
      bindings =
        foo: "abc"
      context =
        request:
          resource:
            bindings:
              foo: "abc"
              bar: "def"
      assert Actions.bindings bindings, context

  test "superset", ->
    do ({ bindings, context } = {}) ->
      bindings =
        foo: "abc"
        bar: "def"
        baz: "ghi"
      context =
        request:
          resource:
            bindings:
              foo: "abc"
              bar: "def"
      assert !Actions.bindings bindings, context
  
]

export { bindings }