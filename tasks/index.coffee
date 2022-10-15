import * as t from "@dashkite/genie"
import preset from "@dashkite/genie-presets"
import sky from "@dashkite/sky-presets"

import FS from "node:fs/promises"
import YAML from "js-yaml"

preset t
sky t

t.define "schema", ->
  FS.writeFile "src/policies.schema.json",
    JSON.stringify YAML.load await FS.readFile "src/policies.schema.yaml", "utf8"