import { register } from "./registry"

register "bindings", ( value, { request } ) ->
  { resource } = request
  { bindings } = bindings
  Object.entries value
    .every ( entry ) ->
      bindings[ entry[0] ] == entry[1]
