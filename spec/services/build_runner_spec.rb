require "rails_helper"

describe BuildRunner, '#run' do
  context 'with active repo and opened pull request' do
    it 'creates a build record with violations' do
      repo = create(:repo, :active, github_id: 123)
      payload = stubbed_payload(
        github_repo_id: repo.github_id,
        pull_request_number: 5,
        head_sha: "123abc",
        full_repo_name: repo.name
      )
      build_runner = BuildRunner.new(payload)
      stubbed_style_checker_with_violations
      stubbed_commenter
      stubbed_pull_request
      stubbed_github_api

      build_runner.run
      builds = Build.where(repo_id: repo.id)
      build = builds.first

      expect(builds.size).to eq 1
      expect(build).to eq repo.builds.last
      expect(build.violations.count).to be >= 1
      expect(build.pull_request_number).to eq 5
      expect(build.commit_sha).to eq payload.head_sha
    end

    it 'comments on violations' do
      build_runner = make_build_runner
      commenter = stubbed_commenter
      style_checker = stubbed_style_checker_with_violations
      commenter = Commenter.new(stubbed_pull_request)
      allow(Commenter).to receive(:new).and_return(commenter)
      stubbed_github_api

      build_runner.run

      expect(commenter).to have_received(:comment_on_violations).
        with(style_checker.violations)
    end

    it "comments a maximum number of times" do
      allow(ENV).to receive(:[]).with("HOUND_GITHUB_TOKEN").
        and_return("something")
      stub_const("::BuildRunner::MAX_COMMENTS", 1)
      build_runner = make_build_runner
      stubbed_commenter
      violations = build_list(:violation, 2)
      stubbed_style_checker(violations: violations)
      commenter = Commenter.new(stubbed_pull_request)
      allow(Commenter).to receive(:new).and_return(commenter)
      stubbed_github_api

      build_runner.run

      expect(commenter).to have_received(:comment_on_violations).
        with(violations.take(BuildRunner::MAX_COMMENTS))
    end

    it 'initializes StyleChecker with modified files and config' do
      build_runner = make_build_runner
      pull_request = stubbed_pull_request
      stubbed_style_checker_with_violations
      stubbed_commenter
      stubbed_github_api

      build_runner.run

      expect(StyleChecker).to have_received(:new).with(pull_request)
    end

    it 'initializes PullRequest with payload and Hound token' do
      repo = create(:repo, :active, github_id: 123)
      user = create(:user, token: "user_token")
      user.repos << repo
      payload = stubbed_payload(github_repo_id: repo.github_id)
      build_runner = BuildRunner.new(payload)
      stubbed_pull_request
      stubbed_style_checker_with_violations
      stubbed_commenter
      stubbed_github_api

      build_runner.run

      expect(PullRequest).to have_received(:new).with(payload, user.token)
    end

    it "creates GitHub statuses" do
      repo = create(:repo, :active, github_id: 123)
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
        "Hound is busy reviewing changes..."
      )
      expect(github_api).to have_received(:create_success_status).with(
        "test/repo",
        "headsha",
        "3 violations found."
      )
    end

    it "upserts repository owner" do
      owner_github_id = 56789
      owner_name = "john"
      repo = create(:repo, :active, github_id: 123)
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
      stubbed_style_checker_with_violations
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
      repo = create(:repo, :active, github_id: 123)
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
      allow(build_runner).to receive(:style_checker).and_return(style_checker)
      allow(build_runner).to receive(:pull_request).and_return(pull_request)
      github_api = stubbed_github_api

      build_runner.run

      expect(github_api).to have_received(:create_error_status).with(
        "test/repo",
        "headsha",
        I18n.t(:config_error_status),
        configuration_url
      )
    end
  end

  context 'without active repo' do
    it 'does not attempt to comment' do
      repo = create(:repo, :inactive)
      build_runner = make_build_runner(repo: repo)
      allow(Commenter).to receive(:new)

      build_runner.run

      expect(Commenter).not_to have_received(:new)
    end
  end

  context 'without opened or synchronize pull request' do
    it 'does not attempt to comment' do
      build_runner = make_build_runner
      pull_request = stubbed_pull_request
      allow(pull_request).
        to receive_messages(opened?: false, synchronize?: false)
      allow(Commenter).to receive(:new)

      build_runner.run

      expect(Commenter).not_to have_received(:new)
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
      stubbed_style_checker_with_violations
      stubbed_commenter
      stubbed_pull_request
      stubbed_github_api

      build_runner.run

      expect(analytics).to have_tracked("Build Started").
        for_user(repo.subscription.user).
        with(properties: { name: repo.full_github_name, private: true })
      expect(analytics).to have_tracked("Build Completed").
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

  def make_build_runner(repo: create(:repo, :active, github_id: 123))
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
    }
    double("Payload", defaults.merge(options))
  end

  def stubbed_style_checker_with_violations
    stubbed_style_checker(violations: [build(:violation)])
  end

  def stubbed_style_checker(violations:)
    style_checker = double(:style_checker, violations: violations)
    allow(StyleChecker).to receive(:new).and_return(style_checker)

    style_checker
  end

  def stubbed_commenter
    commenter = double(:commenter).as_null_object
    allow(Commenter).to receive(:new).and_return(commenter)

    commenter
  end

  def stubbed_pull_request
    pull_request = double(
      :pull_request,
      pull_request_files: [double(:file)],
      config: double(:config),
      opened?: true
    )
    allow(PullRequest).to receive(:new).and_return(pull_request)

    pull_request
  end

  def stubbed_pull_request_with_file(filename, file_content)
    file = double_file(filename, file_content)
    double_pull_request_with_files([file])
  end

  def double_file(filename, file_content)
    double(
      "CommitFile",
      filename: filename,
      content: file_content,
      removed?: false
    )
  end

  def double_pull_request_with_files(files)
    double(
      "PullRequest",
      pull_request_files: files,
      opened?: true,
      repository_owner_name: "test"
    )
  end

  def stubbed_style_checker_with_config_file(pull_request, filename, content)
    config = config_for_file(filename, content)
    style_checker = StyleChecker.new(pull_request)
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
