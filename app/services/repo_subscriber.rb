class RepoSubscriber
  pattr_initialize :repo, :user, :card_token

  def self.subscribe(repo, user, card_token)
    new(repo, user, card_token).subscribe
  end

  def self.unsubscribe(repo, user)
    new(repo, user, nil).unsubscribe
  end

  def subscribe
    repo.subscription || create_subscription
  end

  def unsubscribe
    payment_gateway_subscription = payment_gateway_customer.
      retrieve_subscription(repo.subscription.stripe_subscription_id)

    payment_gateway_subscription.unsubscribe(repo.id)

    repo.subscription.destroy
  rescue => error
    report_exception(error)
    nil
  end

  private

  def create_subscription
    plan_selector = PlanSelector.new(user: user, repo: repo)

    plan = if plan_selector.current_plan.open_source?
      plan_selector.next_plan
    else
      plan_selector.current_plan
    end

    payment_gateway_subscription = stripe_customer.find_or_create_subscription(
      plan: plan.id,
      repo_id: repo.id,
    )
    payment_gateway_subscription.subscribe(repo.id)

    repo.create_subscription!(
      user_id: stripe_user.id,
      stripe_subscription_id: payment_gateway_subscription.id,
      price: plan.price,
    )
  rescue => error
    report_exception(error)
    nil
  end

  def report_exception(error)
    options = { user_id: user.id, repo_id: repo.id }
    Raven.capture_exception(error, extra: options)
  end

  def stripe_customer
    find_and_update_stripe_customer || create_stripe_customer
  end

  def find_and_update_stripe_customer
    if stripe_user
      payment_gateway_customer.tap do |customer|
        if card_token.present?
          customer.update_card(card_token)
        end
      end
    end
  end

  def stripe_user
    @_stripe_user ||= if user.stripe_customer_id.present?
      user
    else
      same_org_repos = repo.owner.repos.joins(:subscription)
      if same_org_repos.any?
        same_org_repos.first.subscription.user
      end
    end
  end

  def payment_gateway_customer
    @_payment_gateway_customer ||= PaymentGatewayCustomer.new(stripe_user)
  end

  def create_stripe_customer
    stripe_customer = Stripe::Customer.create(
      email: user.email,
      metadata: { user_id: user.id },
      card: card_token
    )

    user.update(stripe_customer_id: stripe_customer.id)

    PaymentGatewayCustomer.new(user, customer: stripe_customer)
  end
end
