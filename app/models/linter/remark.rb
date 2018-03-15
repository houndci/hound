# frozen_string_literal: true

module Linter
  class Remark < Base
    FILE_REGEXP = /.+\.(?:md|markdown)\z/

    private

    def job_class
      LintersJob
    end
  end
end
