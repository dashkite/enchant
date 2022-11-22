import { register } from "./registry"

import { confidential } from "panda-confidential"
Confidential = confidential()
{ Message, hash, convert } = Confidential

register "hash", ( value ) ->
  message = Message.from "base36", value
  hash message
    .to "base36"
