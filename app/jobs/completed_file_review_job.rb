class CompletedFileReviewJob
  @queue = :high

  # The following parameters are required for this job to run.
  # filename
  # commit_sha
  # pull_request_number
  # patch
  # violations
  #   [{ line: 123, message: "WAT" }]
  def self.perform(attributes)
    CompleteFileReview.run(attributes)
  rescue ActiveRecord::RecordNotFound
    Resque.enqueue_in(30, self, attributes)
  rescue Resque::TermException
    Resque.enqueue(self, attributes)
  end
end
