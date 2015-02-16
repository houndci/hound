require "spec_helper"

describe RepoSyncsController, "#create" do
  context "user is refreshing repos" do
    it "will not enqueues repo sync job" do
      token = "usergithubtoken"
      user = create(:user, refreshing_repos: true)
      stub_sign_in(user, token)
      allow(RepoSynchronizationJob).to receive(:perform_later)

      post :create

      expect(RepoSynchronizationJob).
        not_to have_received(:perform_later).with(user.id, token)
    end
  end

  context "user is not refreshing repos" do
    it "enqueues repo sync job" do
      token = "usergithubtoken"
      user = create(:user)
      stub_sign_in(user, token)
      allow(RepoSynchronizationJob).to receive(:perform_later)

      post :create

      expect(RepoSynchronizationJob).
        to have_received(:perform_later).with(user.id, token)
    end
  end
end
