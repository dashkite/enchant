import { Request } from "@dashkite/maeve/sublime"
import { register } from "./registry"

register "host", ( _, { request }) ->
  ( Request.Headers.get request, "host" )?