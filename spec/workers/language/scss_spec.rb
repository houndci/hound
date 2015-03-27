require "rails_helper"

module Language
  describe Scss do
    describe "#run" do
      it "sends file to be linted to SCSS worker" do
        build_worker = create(:build_worker)
        faraday_request = stub_faraday
        worker = Scss.new(
          build_worker,
          pull_request_file,
          stub_repo_config,
          repository_owner_name
        )

        worker.run

        expect(Faraday).to have_received(:post)
        expect(faraday_request).
          to have_received(:url=).with(ENV["SCSS_WORKER_URL"])
        expect(faraday_request).to have_received(:body=).with(
          {
            build_worker_id: build_worker.id,
            build_id: build_worker.build_id,
            config: {
              custom: "custom",
              default: default_config_file
            },
            file: {
              name: "test.scss",
              content: "some content",
              patch_body: ""
            },
            hound_url: ENV["BUILD_WORKERS_URL"],
            token: ENV["BUILD_WORKERS_TOKEN"],
          }.to_json
        )
      end
    end

    def pull_request_file
      PullRequestFile.new("test.scss", "some content", "")
    end

    def default_config_file
      DefaultConfigFile.new(
        "scss.yml",
        repository_owner_name
      ).content
    end

    def stub_faraday
      faraday_request = double("FaradayRequest")
      allow(faraday_request).to receive(:url=)
      allow(faraday_request).to receive(:body=)
      allow(Faraday).to receive(:post).and_yield(faraday_request)

      faraday_request
    end

    def stub_repo_config
      repo_config = double("RepoConfig")
      allow(repo_config).to receive(:for).with("scss").and_return("custom")

      repo_config
    end

    def repository_owner_name
      "foo"
    end
  end
end
