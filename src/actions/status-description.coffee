import { getDescriptionFromStatus } from "@dashkite/maeve/common"
import { register } from "./registry"

register "status description", ( values, { response }) ->
  description = response.description ? 
    getDescriptionFromStatus response.status

  description in values
