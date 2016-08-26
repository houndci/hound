module Linter
  class Ruby < Base
    FILE_REGEXP = /.+\.rb\z/

    private

    def config
      Config::Ruby.new(hound_config, owner: build.repo.owner)
    end

    def job_name
      "RubocopReviewJob"
    end
  end
end
