module Linter
  class Flog < Base
    FILE_REGEXP = /.+\.r(b|ake)\z/

    def file_included?(commit_file)
      commit_file.filename !~ /^(spec|test)\//
    end

    private

    def job_class
      FlogReviewJob
    end
  end
end
