module Linter
  class Swiftlint < Base
    FILE_REGEXP = /.+\.swift\z/

    private

    def job_class
      LintersJob
    end
  end
end
