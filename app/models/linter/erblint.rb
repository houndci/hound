module Linter
  class Erblint < Base
    FILE_REGEXP = /.+(.html.erb)\z/

    def job_class
      LintersJob
    end
  end
end
