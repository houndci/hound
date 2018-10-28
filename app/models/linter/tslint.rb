module Linter
  class Tslint < Base
    FILE_REGEXP = /.+\.ts[x]?\z/

    private

    def job_class
      TslintReviewJob
    end
  end
end
