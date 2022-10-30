import { register } from "./registry"

register "headers", ( headers, { response } ) ->
  if response?
    Sublime.appendHeaders response, headers
