# frozen_string_literal: true

module Linter
  class Coffeelint < Base
    FILE_REGEXP = /.+\.coffee(\.js)?(\.erb)?\z/

    private

    def job_class
      LintersJob
    end
  end
end
