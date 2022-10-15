decorate = ( policies, handler ) ->
  ( request ) ->
    handler request

export {
  decorate
}