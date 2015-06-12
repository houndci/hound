App.factory 'Account', ['$resource', ($resource) ->
  $resource '/account', null, {
    'update': { method: 'PUT' }
  }
]
