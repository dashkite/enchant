import { register } from "./registry"

import { confidential } from "panda-confidential"
Confidential = confidential()
{ EncryptionKeyPair, SharedKey, Message, encrypt } = Confidential

register "encrypt", ( target ) ->
  keyPair = EncryptionKeyPair.from "base64",
    await getSecret target["key pair"]
  key = SharedKey.create keyPair
  message = Message.from "utf8", target.value
  ( await encrypt key, message ).to "base36"