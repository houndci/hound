class PlanSelector
  BULK_ID = "bulk".freeze
  MARKETPLACE_URL = ENV.fetch(
    "MARKETPLACE_URL",
    "https://www.github.com/marketplace/hound"
  )

  delegate :owner, to: :repo, allow_nil: true

  def initialize(user:, repo: nil)
    @user = user
    @repo = repo || user.first_active_private_repo
  end

  def paywall?
    owner.stripe_customer_id.blank? && marketplace_plan_id.blank?
  end

  def upgrade?
    if marketplace_plan?
      owner.active_private_repos_count + 1 > current_plan.allowance
    else
      owner.recent_builds >= current_plan.allowance
    end
  end

  def marketplace_plan?
    marketplace_plan_id.present?
  end

  def current_plan
    if marketplace_plan?
      plans.detect { |plan| plan.id == marketplace_plan_id }
    else
      if owner
        plans.detect do |plan|
          plan.id == owner.payment_gateway_subscription.plan
        end || free_plan
      else
        free_plan
      end
    end
  end

  def next_plan
    current_plan_index = plans.index(current_plan)
    if current_plan_index
      plans[current_plan_index + 1] || plans.last
    end
  end

  def current_marketplace_plan
    plans.detect do |plan|
      plan.range.include?(owner.active_private_repos_count)
    end
  end

  def plans
    @_plans ||= plan_class::PLANS.map { |plan| plan_class.new(**plan) }
  end

  private

  attr_reader :user, :repo

  def free_plan
    plan_class.new(**plan_class::PLANS[0])
  end

  def plan_class
    marketplace_plan? ? GitHubPlan : StripePlan
  end

  def marketplace_plan_id
    owner&.marketplace_plan_id
  end

  def marketplace_upgrade_url
    "#{MARKETPLACE_URL}/order/#{next_plan.slug}?account=#{repo&.owner&.name}"
  end
end
