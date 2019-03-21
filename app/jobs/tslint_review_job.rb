class TslintReviewJob < ApplicationJob
  sidekiq_options queue: :tslint_review
end
