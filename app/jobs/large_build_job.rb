# frozen_string_literal: true

class LargeBuildJob < ApplicationJob
  include Buildable

  queue_as :low
end
