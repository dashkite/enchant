import { test, success } from "@dashkite/amen"
import print from "@dashkite/amen-console"
import assert from "@dashkite/assert"

# MUT
import { Actions } from "../src/actions"

# test modules
import * as ActionTests from "./actions"

# mock fetch that just runs locally
globalThis.Sky =
  fetch: ( request ) ->

do ->

  print await test "Enchant", [

    test "Actions", do ->
      for name, tests of  ActionTests
        test name, tests

  ]

  process.exit success