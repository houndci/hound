require 'spec_helper'

describe BuildRunner, '#valid?' do
  context 'with active repo' do
    context 'with valid payload action' do
      it 'returns true' do
        payload = double(:payload, github_repo_id: 123, valid_action?: true)
        create(:repo, :active, github_id: payload.github_repo_id)
        runner = BuildRunner.new(payload)

        expect(runner).to be_valid
      end
    end

    context 'with invalid payload action' do
      it 'returns true' do
        payload = double(:payload, github_repo_id: 123, valid_action?: false)
        create(:repo, :active, github_id: payload.github_repo_id)
        runner = BuildRunner.new(payload)

        expect(runner).not_to be_valid
      end
    end
  end

  context 'with inactive repo' do
    it 'returns false' do
      payload = double(:payload, github_repo_id: 123)
      create(:repo, :inactive, github_id: payload.github_repo_id)
      runner = BuildRunner.new(payload)

      expect(runner).not_to be_valid
    end
  end
end

describe BuildRunner, '#run' do
  it 'creates a build record with violations' do
    repo = create(:repo, :active, github_id: 123)
    build_runner = BuildRunner.new(stubbed_payload(repo))
    stubbed_style_checker_with_violations
    stubbed_commenter
    stubbed_pull_request
    stubbed_file_collection

    expect { build_runner.run }.to change { Build.count }.by(1)
    expect(Build.last).to eq repo.builds.last
    expect(Build.last.violations).to have_at_least(1).violation
  end

  it 'comments on violations' do
    repo = create(:repo, :active, github_id: 123)
    build_runner = BuildRunner.new(stubbed_payload(repo))
    commenter = stubbed_commenter
    style_checker = stubbed_style_checker_with_violations
    pull_request = stubbed_pull_request
    stubbed_file_collection

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
    file_collection = stubbed_file_collection
    stubbed_style_checker_with_violations
    stubbed_commenter

    build_runner.run

    expect(StyleChecker).to have_received(:new).with(
      file_collection.relevant_files,
      pull_request.config
    )
  end

  it 'initializes FileCollection with pull request files' do
    repo = create(:repo, :active, github_id: 123)
    build_runner = BuildRunner.new(stubbed_payload(repo))
    pull_request = stubbed_pull_request
    stubbed_file_collection
    stubbed_style_checker_with_violations
    stubbed_commenter

    build_runner.run

    expect(FileCollection).to have_received(:new).with(
      pull_request.pull_request_files
    )
  end

  it 'initializes PullRequest with payload and Hound token' do
    repo = create(:repo, :active, github_id: 123)
    payload = stubbed_payload(repo)
    build_runner = BuildRunner.new(payload)
    stubbed_pull_request
    stubbed_file_collection
    stubbed_style_checker_with_violations
    stubbed_commenter

    build_runner.run

    expect(PullRequest).to have_received(:new).with(
      payload,
      ENV['HOUND_GITHUB_TOKEN']
    )
  end

  def stubbed_payload(repo)
    double(:payload, github_repo_id: repo.github_id)
  end

  def stubbed_style_checker_with_violations
    violations = [double(:violation)]
    style_checker = double(:style_checker, violations: violations)
    StyleChecker.stub(new: style_checker)

    style_checker
  end

  def stubbed_commenter
    commenter = double(:commenter).as_null_object
    Commenter.stub(new: commenter)

    commenter
  end

  def stubbed_pull_request
    pull_request = double(
      :pull_request,
      pull_request_files: [double(:file)],
      config: double(:config)
    )
    PullRequest.stub(new: pull_request)

    pull_request
  end

  def stubbed_file_collection
    file_collection = double(:file_collection, relevant_files: [double(:file)])
    FileCollection.stub(new: file_collection)

    file_collection
  end
end
