import { Messages } from "@dashkite/messages"
import data from "./data"

messages = Messages.create()
messages.add data

message = ( code, context ) -> messages.message code, context

export {
  message
  messages
}
