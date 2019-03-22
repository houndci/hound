class CompletedFileReviewJob < ApplicationJob
  sidekiq_options queue: :medium

  # The following parameters are required for this job to run;
  # - filename
  # - commit_sha
  # - pull_request_number
  # - patch
  # - violations (e.g. [{ line: 123, message: "WAT" }])
  def perform(attributes)
    CompleteFileReview.call(attributes)
  end
end
