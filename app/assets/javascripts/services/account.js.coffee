App.factory "Account", ["$resource", ($resource) ->
  $resource(
    "/account",
    {}, # no default params
    update:
      method: "patch"
  )
]
