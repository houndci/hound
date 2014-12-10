App.factory 'Repo', ['$resource', ($resource) ->
  $resource '/repos/:id.json', {id: '@id'},
    activate:
      method: 'POST', url: 'repos/:id/activation'
    deactivate:
      method: 'POST', url: 'repos/:id/deactivation'
]
