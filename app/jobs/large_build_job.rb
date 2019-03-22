class LargeBuildJob < ApplicationJob
  include Buildable

  sidekiq_options queue: :low
end
