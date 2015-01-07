require 'spec_helper'

describe RepoSyncsController, '#create' do
  it 'enqueues repo sync job' do
    token = "usergithubtoken"
    user = create(:user)
    stub_sign_in(user, token)
    allow(RepoSynchronizationJob).to receive(:perform_later)

    post :create

    expect(RepoSynchronizationJob).
      to have_received(:perform_later).with(user.id, token)
  end
end
