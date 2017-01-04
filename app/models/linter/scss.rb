module Linter
  class Scss < Base
    FILE_REGEXP = /.+\.scss\z/

    private

    def config
      Config::Scss.new(hound_config, owner: owner)
    end
  end
end
