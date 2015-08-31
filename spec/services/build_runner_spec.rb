require "rails_helper"

describe BuildRunner, '#run' do
  context 'with active repo and opened pull request' do
    it 'creates a build record with violations' do
      repo = create(:repo, :active)
      payload = stubbed_payload(
        github_repo_id: repo.github_id,
        pull_request_number: 5,
        head_sha: "123abc",
        full_repo_name: repo.name
      )
      build_runner = BuildRunner.new(payload)
      stubbed_style_checker(violations: [build(:violation)])
      stubbed_commenter
      stubbed_pull_request
      stubbed_github_api

      build_runner.run
      builds = Build.where(repo_id: repo.id)
      build = builds.first

      expect(builds.size).to eq 1
      expect(build).to eq repo.builds.last
      expect(build.violations.count).to eq 1
      expect(build.pull_request_number).to eq 5
      expect(build.commit_sha).to eq payload.head_sha
      expect(build.payload).to eq ({ payload_stuff: "test" }).to_json
    end

    it "runs the BuildReport to finalize the build" do
      build_runner = make_build_runner
      stubbed_github_api
      pull_request = stubbed_pull_request
      stubbed_style_checker
      allow(BuildReport).to receive(:run)

      build_runner.run

      expect(BuildReport).to have_received(:run).with(
        build: Build.last,
        pull_request: pull_request,
        token: Hound::GITHUB_TOKEN,
      )
    end

    it "reviews files via style checker" do
      build_runner = make_build_runner
      pull_request = stubbed_pull_request
      style_checker = stubbed_style_checker
      stubbed_commenter
      stubbed_github_api

      build_runner.run

      expect(style_checker).to have_received(:review_files)
    end

    it 'initializes PullRequest with payload and Hound token' do
      repo = create(:repo, :active)
      user = create(:user, token: "user_token")
      user.repos << repo
      payload = stubbed_payload(github_repo_id: repo.github_id)
      build_runner = BuildRunner.new(payload)
      stubbed_pull_request
      stubbed_style_checker
      stubbed_commenter
      stubbed_github_api

      build_runner.run

      expect(PullRequest).to have_received(:new).with(payload, user.token)
    end

    it "creates GitHub statuses" do
      repo = create(:repo, :active)
      payload = stubbed_payload(
        github_repo_id: repo.github_id,
        full_repo_name: "test/repo",
        head_sha: "headsha"
      )
      build_runner = BuildRunner.new(payload)
      stubbed_pull_request
      violations = [
        build(:violation),
        build(:violation, messages: ["wrong", "bad"]),
      ]
      stubbed_style_checker(violations: violations)
      stubbed_commenter
      github_api = stubbed_github_api

      build_runner.run

      expect(github_api).to have_received(:create_pending_status).with(
        "test/repo",
        "headsha",
        I18n.t(:pending_status),
      )
      expect(github_api).to have_received(:create_success_status).with(
        "test/repo",
        "headsha",
        I18n.t(:complete_status, count: 3),
      )
    end

    it "upserts repository owner" do
      owner_github_id = 56789
      owner_name = "john"
      repo = create(:repo, :active)
      payload = stubbed_payload(
        github_repo_id: repo.github_id,
        full_repo_name: "test/repo",
        head_sha: "headsha",
        repository_owner_id: owner_github_id,
        repository_owner_name: owner_name,
        repository_owner_is_organization?: true,
      )
      build_runner = BuildRunner.new(payload)
      stubbed_pull_request
      stubbed_style_checker
      stubbed_commenter
      stubbed_github_api

      build_runner.run

      owner_attributes = Owner.first.slice(:name, :github_id, :organization)
      expect(owner_attributes).to eq(
        "name" => owner_name,
        "github_id" => owner_github_id,
        "organization" => true
      )
      expect(repo.reload.owner).to eq Owner.first
    end

    it "fails the GitHub status with invalid config" do
      repo = create(:repo, :active)
      payload = stubbed_payload(
        github_repo_id: repo.github_id,
        full_repo_name: "test/repo",
        head_sha: "headsha"
      )
      build_runner = BuildRunner.new(payload)
      pull_request = stubbed_pull_request_with_file("random.js", "")
      style_checker = stubbed_style_checker_with_invalid_javascript_config(
        pull_request
      )
      allow(StyleChecker).to receive(:new).and_return(style_checker)
      allow(PullRequest).to receive(:new).and_return(pull_request)
      github_api = stubbed_github_api

      build_runner.run

      expect(github_api).to have_received(:create_error_status).with(
        "test/repo",
        "headsha",
        I18n.t(:config_error_status, filename: "javascript.json"),
        configuration_url
      )
    end
  end

  context "when the repo is not active" do
    it "does not create a build" do
      repo = create(:repo, :inactive)
      build_runner = make_build_runner(repo: repo)

      build_runner.run

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

      build_runner.run

      expect(repo.builds).to be_empty
    end
  end

  context "with subscribed private repo and opened pull request" do
    it "tracks build events" do
      repo = create(:repo, :active, private: true)
      create(:subscription, repo: repo)
      payload = stubbed_payload(
        github_repo_id: repo.github_id,
        full_repo_name: repo.name
      )
      build_runner = BuildRunner.new(payload)
      stubbed_style_checker
      stubbed_commenter
      stubbed_pull_request
      stubbed_github_api

      build_runner.run

      expect(analytics).to have_tracked("Build Started").
        for_user(repo.subscription.user).
        with(properties: { name: repo.full_github_name, private: true })
    end
  end

  context "with expired token" do
    it "removes the expired token" do
      repo = create(:repo, :active)
      user = create(:user, token: "expired_token")
      repo.users << user
      build_runner = make_build_runner(repo: repo)
      github_api = stubbed_github_api
      allow(github_api).to receive(:create_pending_status).
        and_raise(Octokit::Unauthorized)

      expect { build_runner.run }.to raise_error BuildRunner::ExpiredToken
      expect(user.reload.token).to be_nil

      expect { build_runner.run }.to raise_error Octokit::Unauthorized
    end
  end

  context "when user's token doesn't have access to the repo" do
    it "removes the repo from user" do
      reachable_repo = create(:repo, :active)
      unreachable_repo = create(:repo, :active)
      user = create(:user, token: "user_test_token")
      user.repos += [reachable_repo, unreachable_repo]
      payload = stubbed_payload(
        github_repo_id: unreachable_repo.github_id,
        full_repo_name: unreachable_repo.name,
      )
      build_runner = BuildRunner.new(payload)
      github_api = stubbed_github_api
      allow(github_api).to receive(:create_pending_status).
        and_raise(Octokit::NotFound)

      expect { build_runner.run }.to raise_error Octokit::NotFound

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

      begin
        build_runner.run
      rescue ActiveRecord::StatementInvalid
        # noop
      end

      expect(Resque).not_to have_received(:enqueue)
    end

    def force_fail_build_creation
      allow(SecureRandom).to receive(:uuid)
    end
  end

  def make_build_runner(repo: create(:repo, :active))
    payload = stubbed_payload(github_repo_id: repo.github_id)
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

  def stubbed_style_checker(violations: [])
    file_review = build(:file_review, :completed, violations: violations)
    style_checker = double("StyleChecker", review_files: nil)
    allow(StyleChecker).to receive(:new) do |*args|
      build = args[1]
      build.file_reviews << file_review
    end.and_return(style_checker)

    style_checker
  end

  def stubbed_commenter
    commenter = double(:commenter).as_null_object
    allow(Commenter).to receive(:new).and_return(commenter)

    commenter
  end

  def stubbed_pull_request(files = [double("CommitFile")])
    head_commit = double(
      "HeadCommit",
      sha: "headsha",
      repo_name: "test/repo",
      file_content: "",
    )
    pull_request = double(
      "PullRequest",
      commit_files: files,
      config: double(:config),
      opened?: true,
      head_commit: head_commit,
      repository_owner_name: "test",
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

  def stubbed_style_checker_with_config_file(pull_request, filename, content)
    config = config_for_file(filename, content)
    style_checker = StyleChecker.new(pull_request, build(:build))
    allow(style_checker).to receive(:config).and_return(config)

    style_checker
  end

  def stubbed_style_checker_with_invalid_javascript_config(pull_request)
    stubbed_style_checker_with_config_file(
      pull_request,
      "javascript.json",
      invalid_json
    )
  end

  def invalid_json
    <<-EOS.strip_heredoc
      {
        "predef": ["myGlobal",]
      }
    EOS
  end

  def stubbed_github_api
    github_api = double(
      "GithubApi",
      create_pending_status: nil,
      create_success_status: nil,
      create_error_status: nil
    )
    allow(GithubApi).to receive(:new).and_return(github_api)

    github_api
  end

  def stub_commit(configuration)
    commit = double("Commit")
    hound_config = configuration.delete(:hound_config)
    allow(commit).to receive(:file_content)
    allow(commit).to receive(:file_content).
      with(RepoConfig::HOUND_CONFIG).and_return(hound_config)
    stub_configuration_for_commit(configuration, commit)

    commit
  end

  def stub_configuration_for_commit(configuration, commit)
    configuration.each do |filename, contents|
      allow(commit).to receive(:file_content).
        with(filename).and_return(contents)
    end
  end

  def config_for_file(file_path, content)
    hound_config = <<-EOS.strip_heredoc
      java_script:
        enabled: true
        config_file: #{file_path}
    EOS

    commit = stub_commit(
      hound_config: hound_config,
      "#{file_path}" => content
    )

    RepoConfig.new(commit)
  end

  def configuration_url
    Rails.application.routes.url_helpers.configuration_url(host: ENV["HOST"])
  end
end
