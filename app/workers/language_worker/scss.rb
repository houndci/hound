module LanguageWorker
  class Scss < Base
    def run
      connection.post("/", body: worker_payload.to_json)
    end

    private

    def worker_payload
      {
        build_worker_id: build_worker.id,
        build_id: build.id,
        config: config,
        file: file,
        hound_url: ENV.fetch("BUILD_WORKERS_URL"),
      }
    end

    def file
      {
        name: filename,
        content: content
      }
    end

    def config
      {
        custom: custom_config,
        default: default_config
      }
    end

    def custom_config
      repo_config.for(name).to_s
    end

    def default_config
      DefaultConfigFile.new(
        default_config_file,
        pull_request.repository_owner_name
      ).content
    end

    def connection
      @connection ||= Faraday.new(url: ENV.fetch("SCSS_WORKER_URL"))
    end

    def default_config_file
      "scss.yml"
    end
  end
end
