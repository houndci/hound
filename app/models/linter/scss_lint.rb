module Linter
  class ScssLint < Base
    FILE_REGEXP = /.+\.scss\z/

    private

    def job_class
      LintersJob
    end
  end
end
