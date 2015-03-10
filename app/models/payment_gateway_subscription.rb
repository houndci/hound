class PaymentGatewaySubscription
  attr_reader :stripe_subscription

  delegate(
    :id,
    :metadata,
    :save,
    :delete,
    :quantity,
    :discount,
    to: :stripe_subscription,
  )

  def initialize(stripe_subscription, new_subscription: false)
    @stripe_subscription = stripe_subscription
    @new_subscription = new_subscription
  end

  def subscribe(repo_id)
    append_repo_id_to_metadata(repo_id)
    if existing_subscription?
      increment_quantity
    end
  end

  def unsubscribe(repo_id)
    if stripe_subscription.quantity > 1
      remove_repo_id_from_metadata(repo_id)
      decrement_quantity
    else
      delete
    end
  end

  def increment_quantity
    stripe_subscription.quantity += 1
    save
  end

  def decrement_quantity
    stripe_subscription.quantity -= 1
    save
  end

  def plan
    stripe_subscription.plan.id
  end

  def plan_amount
    stripe_subscription.plan.amount
  end

  def plan_name
    stripe_subscription.plan.name
  end

  def existing_subscription?
    !@new_subscription
  end

  private

  def current_repo_ids
    if metadata["repo_ids"]
      metadata["repo_ids"].split(",")
    else
      Array(metadata["repo_id"])
    end
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
