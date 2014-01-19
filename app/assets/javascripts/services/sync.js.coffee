App.factory 'Sync', ['$resource', ($resource) ->
  $resource '/repo_syncs/:id', {id: '@id'}
]
