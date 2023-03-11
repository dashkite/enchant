import { Actions } from "./actions"
import { Expression } from "./expression"

Action =

  apply: ({ name, value, action }, context ) ->
    value = if action?
      await Action.apply action, context
    else if value?
      value
    value = Expression.apply value, context

    result = value
    for _n in name.split "|"
      _m = _n.trim()
      if ( _f = Actions[ _m ] )?
        # console.log "enchant: action", _m
        result = await _f result, context
        # console.log "enchant: action result", result
        result = Expression.apply result, context
        # console.log "enchant: action result after expansion", result
      else
        throw new Error "enchant: bad action name [ #{ _m } ]"
    result

export {
  Action
}