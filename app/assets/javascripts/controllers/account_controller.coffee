App.controller "accountController", [
  "$scope",
  "$window",
  "Account",
  "StripeCheckout",
  "CreditCard",
  ($scope, $window, Account, StripeCheckout, CreditCard) ->
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

    $scope.updateEmail = ->
      account = new Account(billable_email: $scope.billableEmail)
      account.$update().then((response)->
        $scope.updateSucceeded = true
        $scope.updateFailed = false
      ).catch((response) ->
        console.log(response)
        $scope.updateSucceeded = false
        $scope.updateFailed = true
      )
]
