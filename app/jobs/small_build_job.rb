class SmallBuildJob < ApplicationJob
  queue_as :medium

  include Buildable
end
