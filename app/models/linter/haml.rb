module Linter
  class Haml < Base
    FILE_REGEXP = /.+\.haml\z/

    private

    def config
      Config::Haml.new(hound_config, owner: owner)
    end
  end
end
