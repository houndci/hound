shared_examples "Language not moved to IronWorker" do
  describe "#run" do
    it "sends violations to hound" do
      build_worker = create(:build_worker)
      pull_request = double("PullRequest", repository_owner_name: "foo")
      faraday_request = stub_faraday
      worker = described_class.new(
        build_worker,
        pull_request_file,
        stub_repo_config,
        pull_request
      )

      worker.run

      expect(Faraday).to have_received(:post)
      expect(faraday_request).to have_received(:url=).with(ENV["BUILD_WORKERS_URL"])
      expect(faraday_request).to have_received(:token_auth).with(ENV.fetch("BUILD_WORKERS_TOKEN"))
      expect(faraday_request).to have_received(:body=).with(
        {
          build_worker_id: build_worker.id,
          build_id: build_worker.build_id,
          violations: violations,
          file: {
            name: "test.foo",
            content: content,
            patch_body: ""
          }
        }.to_json
      )
    end
  end

  def pull_request_file
    PullRequestFile.new("test.foo", content, "")
  end

  def violations
    [
      {
        line_number: 1,
        messages: messages,
      }
    ]
  end

  def stub_faraday
    faraday_request = double("FaradayRequest")
    allow(faraday_request).to receive(:url=)
    allow(faraday_request).to receive(:token_auth)
    allow(faraday_request).to receive(:body=)
    allow(Faraday).to receive(:post).and_yield(faraday_request)

    faraday_request
  end

  def stub_repo_config
    repo_config = double("RepoConfig")
    allow(repo_config).to receive(:for).with(language).and_return({})

    repo_config
  end
end
