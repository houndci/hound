require 'spec_helper'

describe RepoInformationJob do
  it 'is retryable' do
    expect(RepoInformationJob).to be_a(Retryable)
  end

  it 'collects repo privacy and organization from GitHub' do
    repo = create(:repo, private: false, in_organization: false)
    github_token = 'token'
    stub_repo_with_org_request(repo.full_github_name, github_token)

    RepoInformationJob.perform(repo.id, github_token)

    repo.reload
    expect(repo).to be_private
    expect(repo).to be_in_organization
  end

  it 'retries when Resque::TermException is raised' do
    User.stub(:find).and_raise(Resque::TermException.new(1))
    Resque.stub(:enqueue)
    user_id = 'userid'
    github_token = 'token'

    EmailAddressJob.perform(user_id, github_token)

    expect(Resque).to have_received(:enqueue).with(
      EmailAddressJob,
      user_id,
      github_token
    )
  end
end
