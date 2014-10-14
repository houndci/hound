class DeactivatePaidRepos
  pattr_initialize :stripe_customer_id

  def self.run(stripe_customer_id)
    new(stripe_customer_id).run
  end

  def run
    user = User.find_by(stripe_customer_id: stripe_customer_id)
    user.subscriptions.each do |subscription|
      subscription.repo.deactivate
    end
  end
end
