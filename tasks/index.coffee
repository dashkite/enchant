import * as t from "@dashkite/genie"
import preset from "@dashkite/genie-presets"
import sky from "@dashkite/sky-presets"

import * as Time from "@dashkite/joy/time"
import FS from "node:fs/promises"
import YAML from "js-yaml"
import Ajv from "ajv/dist/2020"

preset t
sky t

t.define "schema:validate", ->
  ajv = new Ajv
  await Time.sleep 1000
  schema = YAML.load await FS.readFile "build/node/src/policies.schema.json", "utf8"
  ajv.compile schema

t.after "build", "schema:validate"


