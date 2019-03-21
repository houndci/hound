class CredoReviewJob < ApplicationJob
  sidekiq_options queue: :credo_review
end
