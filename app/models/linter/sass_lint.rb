module Linter
  class SassLint < Base
    FILE_REGEXP = /.+\.s(a|c)ss\z/

    def job_class
      LintersJob
    end
  end
end
