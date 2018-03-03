# frozen_string_literal: true

class SmallBuildJob < ApplicationJob
  queue_as :medium

  include Buildable
end
