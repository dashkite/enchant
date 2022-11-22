import { Actions } from "./actions"
import { Expression } from "./expression"

Action =

  apply: ({ name, value, action }, context ) ->
    value = if action?
      await Action.apply action, context
    else if value?
      Expression.apply value, context

    result = value
    for _n in name.split "|"
      _m = _name.trim()
      if ( _f = Action[ _m ] )?
        result = await _f result, context
      else
        throw new Error "enchant: bad action name [ #{ _m } ]"
    result

export {
  Action
}