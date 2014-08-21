require 'spec_helper'

describe BuildRunner, '#run' do
  context 'with active repo and opened pull request' do
    it 'creates a build record with violations' do
      repo = create(:repo, :active, github_id: 123)
      build_runner = BuildRunner.new(stubbed_payload(repo))
      stubbed_style_checker_with_violations
      stubbed_commenter
      stubbed_pull_request

      expect { build_runner.run }.to change { Build.count }.by(1)
      expect(Build.last).to eq repo.builds.last
      expect(Build.last.violations.size).to be >= 1
      expect(analytics).to have_tracked("Reviewed Repo").
        for_user(repo.users.first).
        with(properties: { name: repo.full_github_name })
    end

    it 'comments on violations' do
      repo = create(:repo, :active, github_id: 123)
      build_runner = BuildRunner.new(stubbed_payload(repo))
      commenter = stubbed_commenter
      style_checker = stubbed_style_checker_with_violations
      pull_request = stubbed_pull_request

      build_runner.run

      expect(commenter).to have_received(:comment_on_violations).with(
        style_checker.violations,
        pull_request
      )
    end

    it 'initializes StyleChecker with modified files and config' do
      repo = create(:repo, :active, github_id: 123)
      build_runner = BuildRunner.new(stubbed_payload(repo))
      pull_request = stubbed_pull_request
      stubbed_style_checker_with_violations
      stubbed_commenter

      build_runner.run

      expect(StyleChecker).to have_received(:new).
        with(pull_request.pull_request_files, pull_request.config)
    end

    it 'initializes PullRequest with payload and Hound token' do
      repo = create(:repo, :active, github_id: 123)
      payload = stubbed_payload(repo)
      build_runner = BuildRunner.new(payload)
      stubbed_pull_request
      stubbed_style_checker_with_violations
      stubbed_commenter

      build_runner.run

      expect(PullRequest).to have_received(:new).with(
        payload,
        ENV['HOUND_GITHUB_TOKEN']
      )
    end
  end

  context 'without active repo' do
    it 'does not attempt to comment' do
      repo = create(:repo, :inactive)
      payload = double(:payload, github_repo_id: repo.github_id)
      runner = BuildRunner.new(payload)
      allow(Commenter).to receive(:new)

      runner.run

      expect(Commenter).not_to have_received(:new)
    end
  end

  context 'without opened or synchronize pull request' do
    it 'does not attempt to comment' do
      repo = create(:repo, :active)
      pull_request = stubbed_pull_request
      payload = double(:payload, github_repo_id: repo.github_id)
      runner = BuildRunner.new(payload)
      allow(pull_request).
        to receive_messages(opened?: false, synchronize?: false)
      allow(Commenter).to receive(:new)

      runner.run

      expect(Commenter).not_to have_received(:new)
    end
  end

  def stubbed_payload(repo)
    double(:payload, github_repo_id: repo.github_id)
  end

  def stubbed_style_checker_with_violations
    violations = [double(:violation)]
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
end
