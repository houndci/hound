class UpdateGitHubPlans
  static_facade :call

  def call
    GitHubPlan::PLANS.each do |plan|
      accounts_for_plan(plan[:id]).each do |account|
        Owner.
          where(github_id: account.id).
          update(marketplace_plan_id: account.marketplace_purchase.plan.id)
      end
    end
  end

  private

  def accounts_for_plan(plan_id)
    GitHubApi.new(AppToken.new.generate).accounts_for_plan(plan_id)
  end
end
