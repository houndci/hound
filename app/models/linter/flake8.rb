module Linter
  class Flake8 < Base
    FILE_REGEXP = /.+\.py\z/

    private

    def enqueue_job(attributes)
      Resque.push(
        "python_review",
        {
          class: "review.Flake8ReviewJob",
          args: [attributes],
        }
      )
    end
  end
end
