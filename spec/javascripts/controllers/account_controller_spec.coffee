#= require spec_helper

describe "accountController", ->
  [scope, http, window, stripeCheckout] = []

  beforeEach(inject ($rootScope, $httpBackend, $controller, CreditCard) ->
    scope = $rootScope.$new()
    http = $httpBackend
    window = {
      alert: ->
    }
    stripeCheckout = {
      open: ->
    }
    $controller("accountController",
      $scope: scope,
      $window: window,
      StripeCheckout: stripeCheckout,
      CreditCard: CreditCard
    )
  )

  afterEach ->
    http.verifyNoOutstandingExpectation()
    http.verifyNoOutstandingRequest()
    http.resetExpectations()

  describe "#showStripeForm", ->
    describe "when update fails", ->
      it "alerts the user", ->
        spyOn(stripeCheckout, "open")
        spyOn(window, "alert")
        stripeToken = {
          id: "tokenid"
        }

        scope.showStripeForm()

        http.expectPUT("/credit_card", card_token: stripeToken.id).respond(422)
        callback = stripeCheckout.open.calls.argsFor(0)[1]
        callback(stripeToken)
        http.flush()

        expect(window.alert).toHaveBeenCalled()
