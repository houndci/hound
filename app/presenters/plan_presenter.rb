# frozen_string_literal: true

class PlanPresenter
  delegate :allowance, :open_source?, :price, :title, to: :plan

  def initialize(plan:, user:)
    @plan = plan
    @user = user
  end

  def current?
    user.current_plan == plan
  end

  def next?
    user.next_plan == plan
  end

  def to_partial_path
    if open_source?
      "plans/open_source"
    else
      "plans/private"
    end
  end

  private

  attr_reader :plan, :user
end
