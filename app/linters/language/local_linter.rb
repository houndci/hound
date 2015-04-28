module Language
  class LocalLinter < Base
    def run
      hound_client = Faraday.new do |client|
        client.request :url_encoded
        client.token_auth(ENV.fetch("BUILD_WORKERS_TOKEN"))
        client.adapter Faraday.default_adapter
      end

      hound_client.put do |request|
        request.url callback_url
        request.body = hound_payload
      end
    end

    attr_implement :style_guide_name

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
        repository_owner_name
      ).violations_in_file(pull_request_file)
    end
  end
end
