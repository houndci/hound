App.directive 'account', ["StripeCheckout", (StripeCheckout) ->
  scope: true
  templateUrl: '/templates/account'

  link: (scope, element, attributes) ->
    scope.hello = ->
      StripeCheckout.open(
        # TODO: name? price?
        sayHello
      )

    sayHello = ->
      alert "hello"
]
