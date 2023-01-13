import { register } from "./registry"

register "match", ({ pattern, target }) ->
  target? &&
    new RegExp pattern
      .test target
