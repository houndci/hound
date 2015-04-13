class LargeBuildJob < ApplicationJob
  include Buildable

  queue_as :low
end
