# frozen_string_literal: true

module Linter
  class CoffeeScript < Base
    FILE_REGEXP = /.+\.coffee(\.js)?(\.erb)?\z/

    private

    def job_name
      "CoffeelintReviewJob"
    end
  end
end
