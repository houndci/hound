class RemoteSubscription
  def initialize(id)
    @id = id
  end

  def plan
    subscription.plan
  end

  private

  attr_reader :id

  def subscription
    @_subscription ||= Stripe::Subscription.retrieve(id)
  end
end
