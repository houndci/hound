# frozen_string_literal: true

require "rails_helper"

describe BuildRunner do
  describe "#call" do
    context "with active repo and opened pull request" do
      it "creates a build record with violations" do
        repo = create(:repo, :active)
        payload = stubbed_payload(
          github_repo_id: repo.github_id,
          pull_request_number: 5,
          head_sha: "123abc",
          full_repo_name: repo.name,
        )
        build_runner = BuildRunner.new(payload)
        stubbed_style_checker(violations: [build(:violation)])
        stubbed_github_api

        build_runner.call

        build = repo.builds.first
        expect(repo.builds.size).to eq 1
        expect(build).to eq repo.builds.last
        expect(build.violations.count).to be >= 1
        expect(build.pull_request_number).to eq 5
        expect(build.commit_sha).to eq payload.head_sha
        expect(build.payload).to eq ({ payload_stuff: "test" }).to_json
      end

      it "initializes PullRequest with payload and Hound token" do
        user = create(:user, token: "user_token")
        repo = create(:repo, :active, users: [user])
        payload = stubbed_payload(github_repo_id: repo.github_id)
        build_runner = BuildRunner.new(payload)
        stubbed_pull_request
        stubbed_style_checker(violations: [build(:violation)])
        stubbed_github_api

        build_runner.call

        expect(PullRequest).to have_received(:new).with(payload, user.token)
      end

      it "sets the GitHub status to pending" do
        repo_name = "test/repo"
        repo = create(:repo, :active, name: repo_name)
        payload = stubbed_payload(
          github_repo_id: repo.github_id,
          full_repo_name: repo_name,
          head_sha: "headsha",
        )
        build_runner = BuildRunner.new(payload)
        violations = [
          build(:violation),
          build(:violation, messages: ["wrong", "bad"]),
        ]
        stubbed_style_checker(violations: violations)
        github_api = stubbed_github_api

        build_runner.call

        expect(github_api).to have_received(:create_pending_status).
          with(repo_name, "headsha", I18n.t(:pending_status))
      end

      it "upserts repository owner" do
        owner_github_id = 56789
        owner_name = "john"
        repo = create(:repo, :active, owner: nil)
        payload = stubbed_payload(
          github_repo_id: repo.github_id,
          full_repo_name: "test/repo",
          head_sha: "headsha",
          repository_owner_id: owner_github_id,
          repository_owner_name: owner_name,
          repository_owner_is_organization?: true,
        )
        build_runner = BuildRunner.new(payload)
        stubbed_style_checker(violations: [build(:violation)])
        stubbed_github_api

        build_runner.call

        expect(repo.reload.owner).to have_attributes(
          name: owner_name,
          github_id: owner_github_id,
          organization: true,
        )
      end
    end

    context "when the repo is not active" do
      it "does not create a build" do
        repo = create(:repo, :inactive)
        build_runner = make_build_runner(repo: repo)

        build_runner.call

        expect(repo.builds).to be_empty
      end
    end

    context "when pull request is not opened or synchronized" do
      it "does not create a build" do
        repo = create(:repo)
        build_runner = make_build_runner(repo: repo)
        pull_request = stubbed_pull_request
        allow(pull_request).
          to receive_messages(opened?: false, synchronize?: false)

        build_runner.call

        expect(repo.builds).to be_empty
      end
    end

    context "with subscribed private repo and opened pull request" do
      it "tracks build events" do
        repo = create(:repo, :active, private: true)
        create(:subscription, repo: repo)
        payload = stubbed_payload(
          github_repo_id: repo.github_id,
          full_repo_name: repo.name,
        )
        build_runner = BuildRunner.new(payload)
        stubbed_style_checker(violations: [build(:violation)])
        stubbed_pull_request
        stubbed_github_api

        build_runner.call

        expect(analytics).to have_tracked("Build Started").
          for_user(repo.subscription.user).
          with(properties: { name: repo.name, private: true })
      end
    end

    context "when the config is invalid" do
      it "sets the status with a helpful message" do
        repo = create(:repo, :active, name: "some/repo")
        build_runner = make_build_runner(repo: repo)
        commit_file = instance_double("CommitFile", filename: "foo.rb")
        pull_request = stubbed_pull_request([commit_file])
        payload = stubbed_payload(
          github_repo_id: repo.github_id,
          commit_sha: "sha123",
        )
        invalid_config_file(pull_request, "config/rubocop.yml" => "!")
        github_api = stubbed_github_api

        build_runner.call

        expect(github_api).to have_received(:create_error_status).with(
          repo.name,
          payload.head_sha,
          I18n.t(:config_error_status, linter_name: "ruby"),
          config_url,
        )
      end
    end

    context "when user's token doesn't have access to the repo" do
      it "removes the repo from user" do
        reachable_repo = create(:repo, :active)
        unreachable_repo = create(:repo, :active)
        user = create(:user, token: "user_test_token")
        user.repos += [reachable_repo, unreachable_repo]
        build_runner = make_build_runner(repo: unreachable_repo)
        github_api = stubbed_github_api
        allow(github_api).to receive(:repository?).and_return(false)
        stubbed_pull_request_with_file("test.rb", "")

        build_runner.call

        expect(user.reload.repos).to eq [reachable_repo]
      end
    end

    context "when build creation fails" do
      it "does not schedule review job" do
        repo = create(:repo, :active)
        build_runner = make_build_runner(repo: repo)
        stubbed_github_api
        stubbed_pull_request_with_file("test.scss", "")
        force_fail_build_creation
        allow(Resque).to receive(:enqueue)

        expect { build_runner.call }.
          to raise_error ActiveRecord::StatementInvalid
        expect(Resque).not_to have_received(:enqueue)
      end

      it "updates commit status with error to avoid hanging build" do
        repo = create(:repo, :active)
        build_runner = make_build_runner(repo: repo)
        github_api = stubbed_github_api
        stubbed_pull_request_with_file("test.scss", "")
        force_fail_build_creation

        expect { build_runner.call }.
          to raise_error ActiveRecord::StatementInvalid
        expect(github_api).to have_received(:create_error_status).with(
          repo.name,
          stubbed_payload.head_sha,
          I18n.t(:hound_error_status, count: 0),
          nil,
        )
      end

      def force_fail_build_creation
        allow(SecureRandom).to receive(:uuid)
      end
    end

    context "when no files need to be reviewed" do
      it "sets the final status as passing" do
        repo = create(:repo, :active)
        build_runner = make_build_runner(repo: repo)
        github_api = stubbed_github_api
        stubbed_pull_request_with_file("foo.whatever", "hello world")

        build_runner.call

        expect(github_api).to have_received(:create_success_status).with(
          repo.name,
          stubbed_payload.head_sha,
          I18n.t(:complete_status, count: 0),
        )
      end
    end

    context "when status cannot be updated" do
      it "does not error" do
        status_not_found = "POST https://api.github.com/repos/foo/bar/" \
          "statuses/123abc: 404 - Not Found // See: https://dev.github.com"
        repo = create(:repo, :active)
        build_runner = make_build_runner(repo: repo)
        github_api = stubbed_github_api
        stubbed_pull_request_with_file("foo.rb", "puts 5 * 6")
        allow(github_api).to receive(:create_pending_status).
          and_raise(Octokit::NotFound.new(message: status_not_found))

        expect { build_runner.call }.not_to raise_error

        expect(repo.builds.size).to eq 1
        expect(repo.builds.map(&:file_reviews).size).to eq 1
      end
    end

    def stubbed_style_checker(violations: [])
      file_review = build(:file_review, :completed, violations: violations)
      style_checker = double("StyleChecker", review_files: nil)
      allow(StyleChecker).to receive(:new) do |*args|
        build = args[1]
        build.file_reviews << file_review
      end.and_return(style_checker)

      style_checker
    end

    def stubbed_pull_request(files = [double("CommitFile")])
      head_commit = double(
        "HeadCommit",
        sha: "headsha",
        repo_name: "test/repo",
        file_content: "",
      )
      stub_commit_to_return_hound_config(head_commit)
      pull_request = double(
        "PullRequest",
        commit_files: files,
        config: double(:config),
        opened?: true,
        head_commit: head_commit,
      )
      allow(PullRequest).to receive(:new).and_return(pull_request)

      pull_request
    end

    def stubbed_pull_request_with_file(filename, file_content)
      commit_file = commit_file_stub(filename, file_content)
      stubbed_pull_request([commit_file])
    end

    def commit_file_stub(filename, file_content)
      double(
        "CommitFile",
        filename: filename,
        content: file_content,
        removed?: false,
        sha: "abcd1234",
        pull_request_number: 1,
        patch: "sometext",
      )
    end

    def stub_commit(configuration)
      commit = double("Commit")
      hound_config = configuration.delete(:hound_config)
      allow(commit).to receive(:file_content)
      allow(commit).to receive(:file_content).
        with(HoundConfig::CONFIG_FILE).and_return(hound_config)
      stub_configuration_for_commit(configuration, commit)

      commit
    end

    def stub_configuration_for_commit(configuration, commit)
      configuration.each do |filename, contents|
        allow(commit).to receive(:file_content).
          with(filename).and_return(contents)
      end
    end

    def configuration_url
      Rails.application.routes.url_helpers.configuration_url(host: ENV["HOST"])
    end
  end

  describe "#set_internal_error" do
    it "will set commit status to failed" do
      repo = create(:repo, :active)
      build_runner = make_build_runner(repo: repo)
      github_api = stubbed_github_api

      build_runner.set_internal_error

      expect(github_api).to have_received(:create_error_status).with(
        repo.name,
        "somesha",
        I18n.t(:hound_error_status),
        nil,
      )
    end
  end

  def make_build_runner(repo: create(:repo, :active))
    payload = stubbed_payload(
      github_repo_id: repo.github_id,
      full_repo_name: repo.name,
    )
    BuildRunner.new(payload)
  end

  def stubbed_payload(options = {})
    defaults = {
      action: "synchronize",
      pull_request_number: 123,
      head_sha: "somesha",
      full_repo_name: "foo/bar",
      repository_owner_id: 456,
      repository_owner_name: "foo",
      repository_owner_is_organization?: true,
      build_data: { payload_stuff: "test" }
    }
    double("Payload", defaults.merge(options))
  end

  def stubbed_github_api
    github_api = instance_double(
      "GithubApi",
      create_pending_status: nil,
      create_success_status: nil,
      create_error_status: nil,
      repository?: true,
    )
    allow(GithubApi).to receive(:new).and_return(github_api)

    github_api
  end

  def invalid_config_file(pull_request, stubs = {})
    stubs.each do |filename, content|
      allow(pull_request.head_commit).to receive(:file_content).
        with(filename).
        and_return(content)
    end
  end

  def config_url
    Rails.application.routes.url_helpers.configuration_url(host: Hound::HOST)
  end
end
