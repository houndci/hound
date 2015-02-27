module LanguageWorker
  class Scss < Base
    DEFAULT_CONFIG_FILENAME = "scss.yml"

    def run
      connection.post("/?code_name=scss", { body: payload })
    end

    private

    def payload
      {
        build_worker_id: build_worker.id,
        build_id: build.id,
        config: {
          custom: custom_config,
          default: default_config
        },
        file: {
          name: filename,
          content: content,
          patch: patch
        },
        hound_url: ENV.fetch("BUILD_WORKERS_URL"),
      }
    end

    def custom_config
      repo_config.for(name)
    end

    def default_config
      DefaultConfigFile.new(
        DEFAULT_CONFIG_FILENAME,
        pull_request.repository_owner_name
      ).content
    end

    def connection
      @connection ||= Faraday.new(url: ENV.fetch("WORKER_URL"))
    end
  end
end
