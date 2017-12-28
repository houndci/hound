module Linter
  class Shellcheck < Base
    FILE_REGEXP = /.+(\.sh|\.zsh|\.bash)\z/

    def job_class
      LintersJob
    end
  end
end
