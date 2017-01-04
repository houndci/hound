module Linter
  class Ruby < Base
    FILE_REGEXP = /.+(\.rb|\.rake)\z/

    private

    def config
      Config::Ruby.new(hound_config, owner: owner)
    end

    def job_name
      "RubocopReviewJob"
    end
  end
end
