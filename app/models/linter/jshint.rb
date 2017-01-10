module Linter
  class Jshint < Base
    FILE_REGEXP = /.+\.js\z/
    IGNORE_FILENAME = ".jshintignore".freeze

    def file_included?(commit_file)
      jsignore.file_included?(commit_file)
    end

    private

    def config
      owner_config.merge(local_config.serialize)
    end

    def local_config
      @_config ||= JshintConfigBuilder.call(hound_config)
    end

    def owner_config
      @_owner_config ||= JshintConfigBuilder.call(owner_hound_config)
    end

    def owner_hound_config
      BuildOwnerHoundConfig.call(build.repo.owner)
    end

    def jsignore
      @jsignore ||= JsIgnore.new(name, hound_config, IGNORE_FILENAME)
    end
  end
end
