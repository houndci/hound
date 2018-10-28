module Linter
  class Credo < Base
    FILE_REGEXP = /.+(\.ex|\.exs)\z/

    private

    def job_class
      CredoReviewJob
    end
  end
end
