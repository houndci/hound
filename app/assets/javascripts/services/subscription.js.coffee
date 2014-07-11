App.factory 'Subscription', ['$resource', ($resource) ->
  $resource '/repos/:repo_id/subscription', repo_id: '@repo_id'
]
