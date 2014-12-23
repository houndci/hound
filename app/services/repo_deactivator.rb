class RepoDeactivator
  def initialize(stripe_customer_id)
    @stripe_customer_id =  stripe_customer_id
  end

  def deactivate_paid_repos
    user = User.find_by(stripe_customer_id: @stripe_customer_id)
    user.subscriptions.each do |subscription|
      subscription.repo.deactivate
    end
  end
end
