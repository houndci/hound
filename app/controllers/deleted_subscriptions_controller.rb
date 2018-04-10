class DeletedSubscriptionsController < ApplicationController
  skip_before_action :authenticate, only: :create

  def create
    payload = request.body.read
    signature = request.env["HTTP_STRIPE_SIGNATURE"]

    event = Stripe::Webhook.construct_event(
      payload,
      signature,
      ENV.fetch("GITHUB_WEBHOOK_SECRET"),
    )
  rescue JSON::ParserError, Stripe::SignatureVerificationError
    head 400
  else
    DeleteSubscriptions.call(params)
    head :ok
  end
end
