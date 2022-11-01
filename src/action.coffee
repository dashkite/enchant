import { Actions } from "./actions"
import { Expression } from "./expression"

Action =

  apply: ({ name, value, action }, context ) ->
    if action?
      value = await Action.apply action, context
    Actions[ name ] ( Expression.apply value ), context

export {
  Action
}