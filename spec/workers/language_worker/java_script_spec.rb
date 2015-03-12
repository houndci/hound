require "spec_helper"

module LanguageWorker
  describe JavaScript do
    describe "#run" do
      it "sends violations to hound" do
        build_worker = create(:build_worker)
        commit_file = commit_file(status: "added")
        repo_config = double("RepoConfig")
        allow(repo_config).to receive(:for).with("java_script").and_return({})
        pull_request = double("PullRequest", repository_owner_name: "foo")
        build_worker_url = ENV["BUILD_WORKERS_URL"]
        connection = double("Connection", post: true)
        allow(Faraday).to receive(:new).with(url: build_worker_url).and_return(connection)
        worker = JavaScript.new(build_worker, commit_file, repo_config, pull_request)

        worker.run

        expect(Faraday).to have_received(:new).with(url: build_worker_url)
        expect(connection).to have_received(:post).with(
          "/",
          {
            body: {
              build_worker_id: build_worker.id,
              build_id: build_worker.build_id,
              violations: violations(build_worker.build_id),
              file: {
                name: "test.js",
                content: content
              }
            }.to_json
          }
        )
      end
    end

    def commit_file(options = {})
      file = double("File", options.reverse_merge(patch: "", filename: "test.js"))
      commit = double(
        :commit,
        repo_name: "test/test",
        sha: "abc",
        file_content: content
      )
      CommitFile.new(file, commit)
    end

    def violations(build_id)
      [
        {
          filename: "test.js",
          line_number: 1,
          messages: ["'blahh' is defined but never used."],
          build_id: build_id
        }
      ]
    end

    def default_config_file
      DefaultConfigFile.new(
        "scss.yml",
        "foo"
      ).content
    end

    def content
      "var blahh = 'blahh';"
    end
  end
end
