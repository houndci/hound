App.factory 'Repo', ['$resource', ($resource) ->
  $resource '/repos/:id', {id: '@id'},
    activate:
      method: 'POST', url: 'repos/:id/activation'
    deactivate:
      method: 'POST', url: 'repos/:id/deactivation'
]
