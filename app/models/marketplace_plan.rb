# frozen_string_literal: true

class MarketplacePlan
  MARKETPLACE_UPGRADE_URL = "https://www.github.com/marketplace/hound"
  PLANS = [
    OpenStruct.new(
      id: 1061,
      repos: 0,
      slug: "MDIyOk1hcmtldHBsYWNlTGlzdGluZ1BsYW4xMDYx",
    ),
    OpenStruct.new(
      id: 1062,
      repos: 4,
      slug: "MDIyOk1hcmtldHBsYWNlTGlzdGluZ1BsYW4xMDYy",
    ),
    OpenStruct.new(
      id: 1063,
      repos: 20,
      slug: "MDIyOk1hcmtldHBsYWNlTGlzdGluZ1BsYW4xMDYz",
    ),
  ].freeze

  def initialize(owner)
    @owner = owner
  end

  def current_plan
    @_current_plan ||= PLANS.
      detect { |plan| marketplace_plan.id == plan.id } || PLANS.first
  end

  def next_plan
    @_next_plan ||= PLANS[
      PLANS.find_index { |plan| plan.id == current_plan.id } + 1
    ]
  end

  def previous_plan
    @_previous_plan ||= current_plan.repos.positive? &&
      PLANS[PLANS.find_index { |plan| plan.id == current_plan.id } - 1]
  end

  def upgrade_url
    "#{MARKETPLACE_UPGRADE_URL}/order/#{next_plan.slug}?account=#{owner.name}"
  end

  def downgrade_url
    "#{MARKETPLACE_UPGRADE_URL}/order/#{previous_plan.slug}?account=" +
      owner.name
  end

  private

  attr_reader :owner

  def marketplace_plan
    @_marketplace_plan ||= app.
      plan_for_account(owner.github_id) || OpenStruct.new(id: nil)
  end

  def app
    @_app ||= GitHubApi.new(AppToken.new.generate)
  end
end
