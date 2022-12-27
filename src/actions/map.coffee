import { register } from "./registry"
import { Action } from "../action"

register "map", ( { from, each, action }, context ) ->
  console.log "MAP ACTION VALUE", action.value
  console.log "MAP ACTION", action
  for item in from
    await Action.apply action, 
      { context..., [ each ]: item }