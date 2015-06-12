App.controller "accountController", [
  "$scope",
  "$window",
  "Account",
  "StripeCheckout",
  "CreditCard",
  ($scope, $window, Account, StripeCheckout, CreditCard) ->
    $scope.account = new Account

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

    $scope.update = ->
      $scope.successMessage = null
      $scope.failureMessage = null

      $scope.account.$update().then(->
        $scope.successMessage = "Email address updated!"
      ).catch(->
        $scope.failureMessage = '''
          There was a problem updating your email. Please try again.
        '''
      )
]
