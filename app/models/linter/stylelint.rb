# frozen_string_literal: true
module Linter
  class Stylelint < Base
    FILE_REGEXP = /.+(\.scss|\.css|\.less)\z/

    def job_class
      LintersJob
    end
  end
end
