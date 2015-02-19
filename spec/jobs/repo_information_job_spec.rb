require 'spec_helper'

describe RepoInformationJob do
  it 'is retryable' do
    expect(RepoInformationJob).to be_a(Retryable)
  end

  it "queue_as low" do
    expect(RepoInformationJob.new.queue_name).to eq("low")
  end

  it 'collects repo privacy and organization from GitHub' do
    repo = create(:repo, private: false, in_organization: false)
    stub_repo_with_org_request(repo.full_github_name)

    RepoInformationJob.perform_now(repo.id)

    repo.reload
    expect(repo).to be_private
    expect(repo).to be_in_organization
  end

  it 'retries when Resque::TermException is raised' do
    repo = create(:repo)
    allow(Repo).to receive(:find).and_raise(Resque::TermException.new(1))
    allow(RepoInformationJob.queue_adapter).to receive(:enqueue)

    job = RepoInformationJob.perform_now(repo.id)

    expect(RepoInformationJob.queue_adapter).
      to have_received(:enqueue).with(job)
  end

  it "sends the exception to Sentry with the repo_id" do
    repo = create(:repo)
    exception = StandardError.new("hola")
    allow(Repo).to receive(:find).and_raise(exception)
    allow(Raven).to receive(:capture_exception)

    RepoInformationJob.perform_now(repo.id)

    expect(Raven).to have_received(:capture_exception).
      with(exception, repo: { id: repo.id })
  end
end
