import { getSecret } from "@dashkite/dolores/secrets"
import { register } from "./registry"

# TODO add Rune lookup
register "issue rune", ( { secret, authorization }) ->
  Runes.issue {
    secret: ( await getSecret secret )
    authorization 
  }