module LanguageWorker
  class Scss < Base
    def run
      connection.post("/?code_name=scss", { body: payload.to_json })
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
          content: content
        },
        hound_url: ENV.fetch("BUILD_WORKERS_URL"),
      }
    end

    def connection
      @connection ||= Faraday.new(url: ENV.fetch("WORKER_URL"))
    end

    def default_config_file
      "scss.yml"
    end
  end
end
