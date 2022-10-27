import { expand } from "@dashkite/polaris"

Expression =
  apply: ( value, context ) ->
    expand value, context

export {
  Expression
}