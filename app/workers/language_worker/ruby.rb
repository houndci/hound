module LanguageWorker
  class Ruby < Base
    def run
      StyleGuide::Ruby.run_from_worker(payload)
    end

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
  end
end
