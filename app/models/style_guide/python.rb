module StyleGuide
  class Python < Base
    LANGUAGE = "python"

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
