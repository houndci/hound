class FlogReviewJob < ApplicationJob
  sidekiq_options queue: :flog_review
end
