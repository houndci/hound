require 'spec_helper'

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
      allow(ENV).to receive(:[]).with("MAX_COMMENTS").and_return("1")
      build_runner = make_build_runner
      stubbed_commenter
      violations = build_list(:violation, 2)
      stubbed_style_checker(violations: violations)
      commenter = Commenter.new(stubbed_pull_request)
      allow(Commenter).to receive(:new).and_return(commenter)
      stubbed_github_api

      build_runner.run

      expect(commenter).to have_received(:comment_on_violations).
        with(violations.take(ENV["MAX_COMMENTS"].to_i))
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
      payload = stubbed_payload(github_repo_id: repo.github_id)
      build_runner = BuildRunner.new(payload)
      stubbed_pull_request
      stubbed_style_checker_with_violations
      stubbed_commenter
      stubbed_github_api

      build_runner.run

      expect(PullRequest).to have_received(:new).with(payload)
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
      stubbed_style_checker_with_violations
      stubbed_commenter
      github_api = stubbed_github_api

      build_runner.run

      expect(github_api).to have_received(:create_pending_status).with(
        "test/repo",
        "headsha",
        "Hound is reviewing changes."
      )
      expect(github_api).to have_received(:create_success_status).with(
        "test/repo",
        "headsha",
        "Hound has reviewed the changes."
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

  def make_build_runner(repo: create(:repo, :active, github_id: 123))
    payload = stubbed_payload(github_repo_id: repo.github_id)
    BuildRunner.new(payload)
  end

  def stubbed_payload(options = {})
    defaults = {
      pull_request_number: 123,
      head_sha: "somesha",
      full_repo_name: "foo/bar"
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
