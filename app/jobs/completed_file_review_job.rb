class CompletedFileReviewJob < ApplicationJob
  queue_as :high

  # The following parameters are required for this job to run.
  # filename
  # commit_sha
  # pull_request_number
  # patch
  # violations
  #   [{ line: 123, message: "WAT" }]
  def perform(attributes)
    CompleteFileReview.call(attributes)
  rescue ActiveRecord::RecordNotFound
    if attempts < Retryable.retry_attempts
      retry_job(wait: 30.seconds)
    end
  end
end
