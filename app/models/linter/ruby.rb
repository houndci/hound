module Linter
  class Ruby < Base
    FILE_REGEXP = /.+(\.rb|\.rake)\z/

    private

    def job_name
      "RubocopReviewJob"
    end
  end
end
