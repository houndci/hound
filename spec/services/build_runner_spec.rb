require "spec_helper"

describe BuildRunner do
  describe "#run" do
    context "with active repo and opened pull request" do
      it "creates a build record" do
        repo = create(:repo, :active, github_id: 123)
        payload = stubbed_payload(
          github_repo_id: repo.github_id,
          pull_request_number: 5,
          head_sha: "123abc",
          full_repo_name: repo.name
        )
        build_runner = BuildRunner.new(payload)
        stubbed_pull_request
        stubbed_github_api

        build_runner.run
        build = Build.find_by(repo_id: repo.id)

        expect(build).to eq repo.builds.last
        expect(build.pull_request_number).to eq 5
        expect(build.commit_sha).to eq payload.head_sha
      end

      it "initializes PullRequest with payload and Hound token" do
        repo = create(:repo, :active, github_id: 123)
        payload = stubbed_payload(github_repo_id: repo.github_id)
        build_runner = BuildRunner.new(payload)
        stubbed_pull_request
        stubbed_github_api

        build_runner.run

        expect(PullRequest).to have_received(:new).with(payload)
      end

      it "creates pending GitHub status" do
        repo = create(:repo, :active, github_id: 123)
        payload = stubbed_payload(
          github_repo_id: repo.github_id,
          full_repo_name: "test/repo",
          head_sha: "headsha"
        )
        build_runner = BuildRunner.new(payload)
        stubbed_pull_request
        github_api = stubbed_github_api

        build_runner.run

        expect(github_api).to have_received(:create_pending_status).with(
          "test/repo",
          "headsha",
          "Hound is busy reviewing changes..."
        )
      end

      it "dispatches workers" do
        repo = create(:repo, :active, github_id: 123)
        payload = stubbed_payload(
          github_repo_id: repo.github_id,
          pull_request_number: 5,
          head_sha: "123abc",
          full_repo_name: repo.name
        )
        build_runner = BuildRunner.new(payload)
        pull_request = stubbed_pull_request
        stubbed_github_api
        style_checker = double("StyleChecker", run: true)
        allow(StyleChecker).to receive(:new).
          and_return(style_checker)

        build_runner.run
        build = Build.find_by(repo_id: repo.id)

        expect(StyleChecker).to have_received(:new).with(pull_request, build)
        expect(style_checker).to have_received(:run)
      end
    end

    context "with subscribed private repo and opened pull request" do
      it "tracks build events" do
        repo = create(:repo, :active, github_id: 123, private: true)
        create(:subscription, repo: repo)
        payload = stubbed_payload(
          github_repo_id: repo.github_id,
          full_repo_name: repo.name
        )
        build_runner = BuildRunner.new(payload)
        stubbed_pull_request
        stubbed_github_api

        build_runner.run

        expect(analytics).to have_tracked("Build Started").
          for_user(repo.subscription.user).
          with(properties: { name: repo.full_github_name, private: true })
      end
    end

    def make_build_runner(repo: create(:repo, :active, github_id: 123))
      payload = stubbed_payload(github_repo_id: repo.github_id)
      BuildRunner.new(payload)
    end

    def stubbed_payload(options = {})
      defaults = {
        pull_request_number: 123,
        head_sha: "somesha",
        full_repo_name: "foo/bar",
        repository_owner_id: 456,
        repository_owner_name: "foo",
        repository_owner_is_organization?: true,
      }
      double("Payload", defaults.merge(options))
    end

    def stubbed_pull_request
      file = double(:file, filename: "a.a")
      head_commit = double("Commit", file_content: "")
      pull_request = double(
        :pull_request,
        head_commit: head_commit,
        pull_request_files: [file],
        config: double(:config),
        opened?: true
      )
      allow(PullRequest).to receive(:new).and_return(pull_request)

      pull_request
    end

    def stubbed_github_api
      github_api = double(
        "GithubApi",
        create_pending_status: nil,
        create_success_status: nil
      )
      allow(GithubApi).to receive(:new).and_return(github_api)

      github_api
    end
  end
end
