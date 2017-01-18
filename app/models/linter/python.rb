module Linter
  class Python < Base
    FILE_REGEXP = /.+\.py\z/

    private

    def enqueue_job(attributes)
      Resque.push(
        "python_review",
        {
          class: "review.PythonReviewJob",
          args: [attributes],
        }
      )
    end
  end
end
