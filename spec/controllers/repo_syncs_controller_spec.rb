require 'spec_helper'

describe RepoSyncsController, '#create' do
  it 'enqueues repo sync job' do
    token = "usergithubtoken"
    user = create(:user)
    stub_sign_in(user, token)
    allow(JobQueue).to receive(:push)

    post :create

    expect(JobQueue).to have_received(:push).
      with(RepoSynchronizationJob, user.id, token)
  end
end
