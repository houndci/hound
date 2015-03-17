shared_examples "Language not moved to IronWorker" do
  describe "#run" do
    it "sends violations to hound" do
      build_worker = create(:build_worker)
      repo_config = double("RepoConfig")
      allow(repo_config).to receive(:for).with(language).and_return({})
      pull_request = double("PullRequest", repository_owner_name: "foo")
      build_worker_url = ENV["BUILD_WORKERS_URL"]
      connection = double("Connection", post: true)
      allow(Faraday).to receive(:new).with(url: build_worker_url).
        and_return(connection)
      worker = described_class.new(
        build_worker,
        commit_file,
        repo_config,
        pull_request
      )

      worker.run

      expect(Faraday).to have_received(:new).with(url: build_worker_url)
      expect(connection).to have_received(:post).with(
        "/",
        body: {
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

  def commit_file
    CommitFile.new("test.foo", content, "")
  end

  def violations
    [
      {
        line_number: 1,
        messages: messages,
      }
    ]
  end
end
