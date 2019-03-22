class ReekReviewJob < ApplicationJob
  sidekiq_options queue: :reek_review
end
