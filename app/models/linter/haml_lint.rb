module Linter
  class HamlLint < Base
    FILE_REGEXP = /.+\.haml\z/

    private

    def job_class
      LintersJob
    end
  end
end
