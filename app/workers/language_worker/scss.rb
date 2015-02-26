module LanguageWorker
  class Scss < Base
    def run
      #TODO add code name in call
      connection.post("/", { payload: payload })
    end

    private

    def payload
      {
        build_worker_id: build_worker.id,
        build_id: build.id,
        config: config,
        file: {
          name: filename,
          content: content,
          patch: patch
        },
        hound_url: ENV.fetch("BUILD_WORKERS_URL"),
      }
    end

    def config
      # TODO some config stuff like merging with default config
    end

    def connection
      @connection ||= Faraday.new(url: ENV.fetch("WORKER_URL"))
    end
  end
end
