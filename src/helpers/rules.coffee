Rule =

  match: ( rule, context ) ->

  resolve: ( rule, context ) ->

  Request:

    apply: ( rule, context ) ->
      await Rule.resolve rule, context
      #...


Rules =
  
  Request: ( rules, context ) ->
    for rule in rules
      break if context.response?
      if Rule.match rule, context
        await Rule.Request.apply rule, context

  Response: ( rules, context ) ->
