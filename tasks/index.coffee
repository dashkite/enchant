import * as t from "@dashkite/genie"
import preset from "@dashkite/genie-presets"
import sky from "@dashkite/sky-presets"
import execa from "execa"

preset t
sky t

t.define "schema:md", ->
  # TODO maybe find a better way to insert this warning? :D
  execa.command "npx wetzel 
    build/node/src/policies.schema.json |
    awk 'BEGIN { print \"> **Warning:** This document 
      is automatically generated. To make changes, edit
      the [schema YAML](../src/policies.schema.yaml).\"}
      { print $0 }' > docs/policies.schema.md",
    shell: true

t.after "build", "schema:md"


