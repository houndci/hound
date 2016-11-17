class PaymentGatewaySubscription
  attr_reader :stripe_subscription, :tier

  delegate(
    :id,
    :metadata,
    :plan=,
    :save,
    :delete,
    :discount,
    to: :stripe_subscription,
  )

  def initialize(stripe_subscription:, tier:)
    @stripe_subscription = stripe_subscription
    @tier = tier
  end

  def subscribe(repo_id)
    append_repo_id_to_metadata(repo_id)
    self.plan = tier.next.id
    save
  end

  def unsubscribe(repo_id)
    remove_repo_id_from_metadata(repo_id)
    self.plan = downgraded_plan
    save
  end

  def plan
    stripe_plan.id
  end

  def plan_amount
    stripe_plan.amount
  end

  def plan_name
    stripe_plan.name
  end

  private

  def current_repo_ids
    if metadata["repo_ids"]
      metadata["repo_ids"].split(",")
    else
      Array(metadata["repo_id"])
    end
  end

  def downgraded_plan
    previous_tier.id
  end

  def previous_tier
    tier.previous
  end

  def stripe_plan
    stripe_subscription.plan
  end

  def append_repo_id_to_metadata(repo_id)
    repo_ids = current_repo_ids + [repo_id]

    if metadata["repo_id"]
      metadata["repo_id"] = nil
    end

    metadata["repo_ids"] = repo_ids.join(",")
  end

  def remove_repo_id_from_metadata(repo_id)
    repo_ids = current_repo_ids.reject { |id| id.to_s == repo_id.to_s }

    if repo_ids.empty?
      metadata["repo_ids"] = nil
    else
      metadata["repo_ids"] = repo_ids.join(",")
    end
  end
end
