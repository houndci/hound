require 'spec_helper'

describe EmailAddressJob do
  it 'is retryable' do
    expect(RepoSynchronizationJob).to be_a(Retryable)
  end

  it 'collects user email from GitHub' do
    user = create(:user)
    github_token = 'token'
    stub_user_emails_request(github_token)

    EmailAddressJob.perform(user.id, github_token)

    expect(user.reload.email_address).to be_present
  end

  it 'downcases the email address' do
    user = create(:user)
    github_token = 'token'
    stub_user_emails_request(github_token)

    EmailAddressJob.perform(user.id, github_token)

    expect(user.reload.email_address).to eq 'primary@example.com'
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
