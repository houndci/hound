require "rails_helper"

describe BuildRunner, '#run' do
  context "with active repo and opened pull request" do
    it "creates a build record" do
      repo = create(:repo, :active, github_id: 123)
      payload = stubbed_payload(
        github_repo_id: repo.github_id,
        pull_request_number: 5,
        head_sha: "123abc",
        full_repo_name: repo.name
      )
      stubbed_pull_request
      stubbed_github_api

      BuildRunner.run(payload)
      build = Build.find_by(repo_id: repo.id)

      expect(build).to eq repo.builds.last
      expect(build.pull_request_number).to eq 5
      expect(build.commit_sha).to eq payload.head_sha
    end

    it "initializes PullRequest with payload and Hound token" do
      repo = create(:repo, :active, github_id: 123)
      payload = stubbed_payload(github_repo_id: repo.github_id)
      stubbed_pull_request
      stubbed_github_api

      BuildRunner.run(payload)

      expect(PullRequest).to have_received(:new).with(payload)
    end

    it "creates pending GitHub status" do
      repo = create(:repo, :active, github_id: 123)
      payload = stubbed_payload(
        github_repo_id: repo.github_id,
        full_repo_name: "test/repo",
        head_sha: "headsha"
      )
      stubbed_pull_request
      github_api = stubbed_github_api

      BuildRunner.run(payload)

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
      pull_request = stubbed_pull_request
      stubbed_github_api
      allow(DispatchWorkers).to receive(:run)

      BuildRunner.run(payload)
      build = Build.find_by(repo_id: repo.id)

      expect(DispatchWorkers).
        to have_received(:run).with(pull_request, build)
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
      stubbed_pull_request
      stubbed_github_api

      BuildRunner.run(payload)

      owner_attributes = Owner.first.slice(:name, :github_id, :organization)
      expect(owner_attributes).to eq(
        "name" => owner_name,
        "github_id" => owner_github_id,
        "organization" => true
      )
      expect(repo.reload.owner).to eq Owner.first
    end

    it "fails the GitHub status with invalid config" do
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
      stubbed_pull_request
      github_api = stubbed_github_api
      allow(RepoConfig).to receive(:new).and_raise(RepoConfig::ParserError)

      BuildRunner.run(payload)

      expect(github_api).to have_received(:create_error_status).with(
        "test/repo",
        "headsha",
        I18n.t(:config_error_status),
        anything
      )
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
      stubbed_pull_request
      stubbed_github_api

      BuildRunner.run(payload)

      expect(analytics).to have_tracked("Build Started").
        for_user(repo.subscription.user).
        with(properties: { name: repo.full_github_name, private: true })
    end
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
      repository_owner_name: "foo",
      opened?: true
    )
    allow(PullRequest).to receive(:new).and_return(pull_request)

    pull_request
  end

  def stubbed_github_api
    github_api = double(
      "GithubApi",
      create_pending_status: nil,
      create_success_status: nil,
      create_error_status: nil,
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
