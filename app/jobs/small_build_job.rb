class SmallBuildJob < ActiveJob::Base
  extend Retryable
  include Buildable

  queue_as :medium
end
