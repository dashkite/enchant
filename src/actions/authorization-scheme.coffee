import * as Type from "@dashkite/joy/type"
import { register } from "./registry"

register "authorization scheme", ( target, { request: { authorization } }) ->
  if Type.isArray authorization
    ( authorization.find ({ scheme }) -> scheme == target )?
  else if authorization?
    authorization.scheme == target
  else
    false
