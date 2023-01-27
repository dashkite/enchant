import { getStatusFromDescription } from "@dashkite/maeve/common"
import { register } from "./registry"

register "ok", ( _, { response }) ->
  if response.status? || response.description?
    status = response.status ? getStatusFromDescription response.description
    200 <= status < 300
  else
    false