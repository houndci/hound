# frozen_string_literal: true

class PlanSerializer < ActiveModel::Serializer
  attributes :current, :name, :price, :allowance

  def current
    scope.current_plan == object
  end

  def name
    object.title
  end
end
