import { Actions } from "./actions"
import { Expression } from "./expression"

Action =

  apply: ({ name, value, action }, context ) ->
    value = if action?
      await Action.apply action, context
    else if value?
      Expression.apply value, context

    Actions[ name ] value, context

export {
  Action
}