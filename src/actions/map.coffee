import { register } from "./registry"
import { Action } from "../action"

register "map", ( { from, each, action }, context ) ->
  console.log "MAP ACTION VALUE", action.value
  console.log "MAP ACTION", action
  results = []
  for item in from
    result = await Action.apply action, 
      { context..., [ each ]: item }
    console.log "MAP ACTION RESULT", result
    if result?
      results.push result
  results