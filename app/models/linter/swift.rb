module Linter
  class Swift < Base
    FILE_REGEXP = /.+\.swift\z/

    private

    def config
      Config::Swift.new(hound_config, owner: owner)
    end
  end
end
