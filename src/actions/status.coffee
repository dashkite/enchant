import { getStatusFromDescription } from "@dashkite/maeve/common"
import { register } from "./registry"

register "status", ( values, { response }) ->
  status = response.status ? getStatusFromDescription response.description
  status in values
