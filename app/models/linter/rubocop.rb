module Linter
  class Rubocop < Base
    FILE_REGEXP = /.+(\.rb|\.rake)\z/

    private

    def job_class
      LintersJob
    end
  end
end
