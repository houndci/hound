module Linter
  class SlimLint < Base
    FILE_REGEXP = /.slim\z/

    def job_class
      LintersJob
    end
  end
end
