module Linter
  class Flake8 < Base
    FILE_REGEXP = /.+\.py\z/

    private

    def enqueue_job(attributes)
      Resque.push(
        "linters",
        {
          class: "LintersJob",
          args: [attributes],
        }
      )
    end
  end
end
