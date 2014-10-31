require 'spec_helper'

describe RepoInformationJob do
  it 'is retryable' do
    expect(RepoInformationJob).to be_a(Retryable)
  end

  it 'collects repo privacy and organization from GitHub' do
    repo = create(:repo, private: false, in_organization: false)
    stub_repo_with_org_request(repo.full_github_name)

    RepoInformationJob.perform(repo.id)

    repo.reload
    expect(repo).to be_private
    expect(repo).to be_in_organization
  end

  it 'retries when Resque::TermException is raised' do
    repo = create(:repo)
    allow(Repo).to receive(:find).and_raise(Resque::TermException.new(1))
    allow(Resque).to receive(:enqueue)

    RepoInformationJob.perform(repo.id)

    expect(Resque).to have_received(:enqueue).with(RepoInformationJob, repo.id)
  end
end
