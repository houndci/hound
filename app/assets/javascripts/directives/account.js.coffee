App.directive "account", ["Account", "StripeCheckout", (Account, StripeCheckout) ->
  scope: true
  templateUrl: "/templates/account"

  link: (scope, element, attributes) ->
    updateToken = (stripeToken) ->
      account = new Account(
        card_token: stripeToken.id
      )

      account.$update().then((response) ->
        console.log(response)
      ).catch(->
        alert("Could not update card information.")
      ).finally(->
        console.log("something happened, at least")
      )

    scope.updateCardInfo = ->
      StripeCheckout.open(
        name: "Hound",
        panelLabel: "Update Card",
        updateToken
      )
]
