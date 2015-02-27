require "spec_helper"

module LanguageWorker
  describe Ruby do
    describe "#run" do
      it "sends violations to hound" do
        build_worker = create(:build_worker)
        commit_file = commit_file(status: "added")
        repo_config = double("RepoConfig")
        allow(repo_config).to receive(:for).with("ruby").and_return("custom")
        pull_request = double("PullRequest", repository_owner_name: "foo")
        build_worker_url = ENV["BUILD_WORKERS_URL"]
        connection = double("Connection", post: true)
        #violations = [
          #"Something",
          #"Another thing"
        #]
        #ruby_style_guide = double("StyleGuide::Ruby", violations_in_file: violations)
        #allow(StyleGuide::Ruby).to receive(:new).and_return(ruby_style_guide)
        allow(Faraday).to receive(:new).with(url: build_worker_url).and_return(connection)
        worker = Ruby.new(build_worker, commit_file, repo_config, pull_request)

        worker.run

        expect(Faraday).to have_received(:new).with(url: build_worker_url)
        expect(connection).to have_received(:post).with(
          "/",
          {
            body: {
              build_worker_id: build_worker.id,
              build_id: build_worker.build_id,
              violations: violations(build_worker.build_id)
            }.to_json
          }
        )
      end
    end

    def commit_file(options = {})
      file = double("File", options.reverse_merge(patch: "", filename: "test.rb"))
      commit = double(
        :commit,
        repo_name: "test/test",
        sha: "abc",
        file_content: "some content"
      )
      CommitFile.new(file, commit)
    end

    def violations(build_id)
      [
        {
          filename: "test.rb",
          line_number: 1,
          messages: ["Final newline missing."],
          patch_position: -1,
          build_id: build_id
        }
      ]
    end
  end
end
