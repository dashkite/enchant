import { register } from "./registry"

register "resource", ( { include, exclude }, { request } ) ->
  { resource } = request
  (( ! exclude? ) || !( resource.name in exclude )) && 
    (( ! include? ) || resource.name in include )
    
