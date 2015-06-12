App.factory 'Account', ['$resource', ($resource) ->
  $resource '/account.json', null, {
    'update': { method: 'PUT' }
  }
]
