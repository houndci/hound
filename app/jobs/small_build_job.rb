class SmallBuildJob < ApplicationJob
  include Buildable

  sidekiq_options queue: :medium
end
