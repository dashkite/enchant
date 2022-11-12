import * as Fn from "@dashkite/joy/function"
import { Action } from "../action"
import { Expression } from "../expression"

Rule =

  match: ({ conditions }, context ) ->
    if conditions?
      for condition in conditions
        if await Action.apply condition, context
          continue
        else
          return false
      true
    else
      true

  resolve: Fn.rtee ( rule, context ) ->
    if rule.context?
      for { name, value, action } in rule.context
        context[ name ] = if value?
          Expression.apply value, context
        else
          await Action.apply action, context

  Request:
    apply: Fn.rtee ({ actions }, context ) ->
      if actions?
        for action in actions
          break if context.response?
          context.$ = await Action.apply action, context

  Response:
    apply: Fn.rtee ({ actions }, context ) ->
      if actions?
        for action in actions
          context.$ = await Action.apply action, context

Rules =
  
  Request: 
    apply: ( rules, context ) ->
      console.log "enchant: applying request rules"
      for rule in rules
        break if context.response?
        console.log "enchant: applying request rule", rule
        if Rule.match rule, context
          await Rule.resolve rule, context
          await Rule.Request.apply rule, context

  Response: 
    apply: ( rules, context ) ->
      console.log "enchant: applying response rules"
      for rule in rules
        console.log "enchant: applying response rule", rule
        if Rule.match rule, context
          await Rule.resolve rule, context
          await Rule.Request.apply rule, context

export {
  Rule
  Rules
}