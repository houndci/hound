class LargeBuildJob < ActiveJob::Base
  extend Retryable
  include Buildable

  queue_as :low
end
