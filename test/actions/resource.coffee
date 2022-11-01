import { test } from "@dashkite/amen"
import assert from "@dashkite/assert"
import { Actions } from "../../src/actions"

scenarios =

  text:

    match:
      resource: "foo"
      request:
        resource:
          name: "foo"

    mismatch:
      resource: "foo"
      request:
        resource:
          name: "bar"

  array:

    match:
      resource: [ "foo" ]
      request:
        resource:
          name: "foo"

    mismatch:
      resource: [ "bar" ]
      request:
        resource:
          name: "foo"

  include:

    match:
      resource: 
        include: [ "foo" ]
      request:
        resource:
          name: "foo"

    mismatch:
      resource:
        include: [ "foo" ]
      request:
        resource:
          name: "bar"      

  exclude:

    match:
      resource: 
        exclude: [ "bar" ]
      request:
        resource:
          name: "foo"

    mismatch:
      resource:
        exclude: [ "bar" ]
      request:
        resource:
          name: "bar"      

resource = do ->

  for name, scenario of scenarios

    test name, [

      test "match", ->
        do ({ resource, request } = scenario.match ) ->
          assert Actions.resource resource, { request }
      
      test "mismatch", ->
        do ({ resource, request } = scenario.mismatch ) ->
          assert !Actions.resource resource, { request }

    ]



export { resource }