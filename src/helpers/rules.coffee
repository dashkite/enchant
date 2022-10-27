import { Action } from "./action"
import { Expression } from "./expression"

Rule =

  match: ({ conditions }, context ) ->
    for condition in conditions
      if await Action.apply condition, context
        continue
      else
        return false
    true

  resolve: ( rule, context ) ->
    for { name, value, action } in rule.context
      context[ name ] = if value?
        Expression.apply value, context
      else
        await Action.apply action, context

  Request:
    apply: ({ actions }, context ) ->
      for actions in action
        break if context.response?
        context.$ = await Action.apply action, context

  Response:
    apply: ( rule, context ) ->
      for actions in action
        context.$ = await Action.apply action, context

Rules =
  
  Request: ( rules, context ) ->
    for rule in rules
      break if context.response?
      if Rule.match rule, context
        await Rule.resolve rule, context
        await Rule.Request.apply rule, context

  Response: ( rules, context ) ->
    for rule in rules
      if Rule.match rule, context
        await Rule.resolve rule, context
        await Rule.Request.apply rule, context

export {
  Rule
  Rules
}