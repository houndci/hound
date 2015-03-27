module Language
  class LegacyWorker < Base
    def run
      Faraday.post do |request|
        request.url = BUILD_WORKERS_URL
        request.token_auth(BUILD_WORKERS_TOKEN)
        request.body = hound_payload.to_json
      end
    end

    private

    def hound_payload
      {
        build_worker_id: build_worker.id,
        build_id: build_worker.build_id,
        violations: violations,
        file: {
          name: filename,
          content: content,
          patch_body: patch_body
        }
      }
    end

    def violations
      violations_from_guide.flat_map do |violation|
        {
          line_number: violation.line_number,
          messages: violation.messages
        }
      end
    end

    def violations_from_guide
      @violations_from_guide ||= style_guide_name.new(
        repo_config,
        pull_request.repository_owner_name
      ).violations_in_file(pull_request_file)
    end

    def style_guide_name
      guide_name = self.class.name.demodulize
      "StyleGuide::#{guide_name}".safe_constantize
    end
  end
end
