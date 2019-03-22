class JshintReviewJob < ApplicationJob
  sidekiq_options queue: :jshint_review
end
