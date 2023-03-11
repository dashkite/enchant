import { register } from "./registry"
import { Action } from "../action"

register "map", ( { from, each, action }, context ) ->
  results = []
  if from? && each? && action?
    for item in from
      result = await Action.apply action, 
        { context..., [ each ]: item }
      if result?
        results.push result
  results