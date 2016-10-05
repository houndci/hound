# frozen_string_literal: true

module Linter
  class CoffeeScript < Base
    FILE_REGEXP = /.+\.coffee(\.js)?(\.erb)?\z/

    private

    def config
      Config::CoffeeScript.new(hound_config, owner: build.repo.owner)
    end

    def job_name
      "CoffeelintReviewJob"
    end
  end
end
