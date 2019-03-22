class EslintReviewJob < ApplicationJob
  sidekiq_options queue: :eslint_review
end
