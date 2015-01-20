App.factory 'CreditCard', ['$resource', ($resource) ->
  $resource '/credit_card', null, {
    'update': { method: 'PUT' }
  }
]
