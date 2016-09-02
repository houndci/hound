module Linter
  class Scss < Base
    FILE_REGEXP = /.+\.scss\z/

    def config
      owner_config.merge(local_config.serialize)
    end

    def owner_config
      ScssConfigBuilder.for(owner_hound_config)
    end

    def owner_hound_config
      BuildOwnerHoundConfig.run(build.repo.owner)
    end

    def local_config
      ScssConfigBuilder.for(hound_config)
    end
  end
end
