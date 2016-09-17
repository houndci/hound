module Linter
  class Scss < Base
    FILE_REGEXP = /.+\.scss\z/

    def config
      owner_config.merge(local_config.serialize)
    end

    def owner_config
      MergeableConfigBuilder.for(owner_hound_config, "scss")
    end

    def owner_hound_config
      BuildOwnerHoundConfig.run(build.repo.owner)
    end

    def local_config
      MergeableConfigBuilder.for(hound_config, "scss")
    end
  end
end
