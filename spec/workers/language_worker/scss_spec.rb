require "spec_helper"

module LanguageWorker
  describe Scss do
    describe "#run" do
      it "sends file to be linted to SCSS worker" do
        build_worker = create(:build_worker)
        commit_file = commit_file(status: "added")
        repo_config = double("RepoConfig")
        allow(repo_config).to receive(:for).with("scss").and_return("custom")
        pull_request = double("PullRequest", repository_owner_name: "foo")
        scss_worker_url = ENV["SCSS_WORKER_URL"]
        connection = double("Connection", post: true)
        allow(Faraday).to receive(:new).with(url: scss_worker_url).
          and_return(connection)
        worker = Scss.new(build_worker, commit_file, repo_config, pull_request)

        worker.run

        expect(Faraday).to have_received(:new).with(url: scss_worker_url)
        expect(connection).to have_received(:post).with(
          "/",
          body: {
            build_worker_id: build_worker.id,
            build_id: build_worker.build_id,
            config: {
              custom: "custom",
              default: default_config_file
            },
            file: {
              name: "test.scss",
              content: "some content"
            },
            hound_url: ENV["BUILD_WORKERS_URL"]
          }.to_json
        )
      end
    end

    def commit_file
      CommitFile.new("test.scss", "some content", "")
    end

    def default_config_file
      DefaultConfigFile.new(
        "scss.yml",
        "foo"
      ).content
    end
  end
end
