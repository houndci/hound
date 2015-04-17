shared_examples "Language not moved to IronWorker" do
  describe "#run" do
    it "sends violations to hound" do
      build_worker = create(:build_worker)
      repository_owner_name = "foo"
      request_body = {
        build_worker_id: build_worker.id,
        build_id: build_worker.build_id,
        violations: violations,
        file: {
          name: "test.foo",
          content: content,
          patch_body: ""
        }
      }
      request_stub = stub_violation_callback(build_worker, request_body)
      worker = described_class.new(
        build_worker,
        pull_request_file,
        stub_repo_config,
        repository_owner_name
      )

      worker.run

      # fails because of url encoded arrays
      # https://github.com/lostisland/faraday/issues/78
      expect(request_stub).to have_been_requested.with(request_body)
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

  def stub_violation_callback(build_worker, request_body)
    stub_request(:put, "https://hound.ngrok.com/build_workers/#{build_worker.id}").
      with(:body => request_body).
      to_return(:status => 200, :body => "", :headers => {})
  end

  def stub_faraday_old
    faraday_request = double("FaradayRequest")
    allow(faraday_request).to receive(:url)
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
