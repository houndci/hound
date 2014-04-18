require 'spec_helper'

describe RepoSyncsController, '#create' do
  it 'enqueues repo sync job' do
    user = create(:user)
    stub_sign_in(user)
    JobQueue.stub(:push)

    post :create

    expect(JobQueue).to have_received(:push).with(
      RepoSynchronizationJob,
      user.id,
      AuthenticationHelper::GITHUB_TOKEN
    )
  end
end
