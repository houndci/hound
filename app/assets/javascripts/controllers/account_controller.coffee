App.controller "accountController", [
  "$scope",
  "$window",
  "StripeCheckout",
  "CreditCard",
  ($scope, $window, StripeCheckout, CreditCard) ->
    updateCustomer = (stripeToken) ->
      user = new CreditCard(card_token: stripeToken.id)
      user.$update().catch(->
        $window.alert("There was an issue updating your card. We have been notified and will contact you soon.")
      )

    $scope.showStripeForm = ->
      StripeCheckout.open(
        buttonText: "Update Card",
        updateCustomer
      )
]
