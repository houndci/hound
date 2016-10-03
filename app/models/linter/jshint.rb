module Linter
  class Jshint < Base
    FILE_REGEXP = /.+\.js\z/
    IGNORE_FILENAME = ".jshintignore".freeze

    delegate :file_included?, to: :jsignore

    private

    def config
      owner_config.merge(local_config.serialize)
    end

    def local_config
      @_config ||= JshintConfigBuilder.for(hound_config)
    end

    def owner_config
      @_owner_config ||= JshintConfigBuilder.for(owner_hound_config)
    end

    def owner_hound_config
      BuildOwnerHoundConfig.run(build.repo.owner)
    end

    def jsignore
      @jsignore ||= JsIgnore.new(name, hound_config, IGNORE_FILENAME)
    end
  end
end
