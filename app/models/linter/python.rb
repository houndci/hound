module Linter
  class Python < Base
    FILE_REGEXP = /.+\.py\z/

    private

    def config
      Config::Python.new(hound_config, owner: owner)
    end

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
