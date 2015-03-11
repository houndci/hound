class FailedReviewJob < ActiveJob::Base
  extend Retryable

  def perform(params)
    # repo_name
    # filename
    # commit
    # content
    # error

    # find build and mark it as failed, probably update GitHub status
  end
end
