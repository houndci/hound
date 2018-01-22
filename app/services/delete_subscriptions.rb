# frozen_string_literal: true

class DeleteSubscriptions
  DELETED_EVENT_TYPE = "customer.subscription.deleted"

  def initialize(params)
    @params = params
  end

  def self.call(*args)
    new(*args).call
  end

  def call
    if event_type == DELETED_EVENT_TYPE
      subscriptions.each do |subscription|
        deactivate_repo(subscription) && subscription.destroy
      end
    end
  end

  private

  attr_reader :params

  def deactivate_repo(subscription)
    RepoActivator.
      new(repo: subscription.repo, github_token: subscription.user.token).
      deactivate
  end

  def subscriptions
    Subscription.where(stripe_subscription_id: subscription_id)
  end

  def subscription_id
    params.dig("data", "object", "id")
  end

  def event_type
    params.dig("type")
  end
end
