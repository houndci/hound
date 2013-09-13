App.factory 'Repo', ['$resource', ($resource) ->
  $resource '/repos/:id', {id: '@id'}, {update: {method: 'PUT'}}
]
