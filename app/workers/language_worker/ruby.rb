module LanguageWorker
  class Ruby < Base
    def run
      hound_connection.post("/", body: hound_payload.to_json)
    end

    private

    def hound_payload
      {
        build_worker_id: build_worker.id,
        build_id: build_worker.build_id,
        violations: violations
      }
    end

    def violations
      violations_from_guide.flat_map do |violation|
        {
          filename: violation.filename,
          line_number: violation.line_number,
          messages: violation.messages,
          patch_position: violation.patch_position,
          build_id: build.id
        }
      end
    end

    def hound_connection
      @hound_connection ||= Faraday.new(url: ENV.fetch("BUILD_WORKERS_URL"))
    end

    def violations_from_guide
      @violations_from_guide ||= StyleGuide::Ruby.new(
        repo_config,
        pull_request.repository_owner_name
      ).violations_in_file(commit_file)
    end
  end
end
