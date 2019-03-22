require "rails_helper"

describe RepoSyncsController, "#create" do
  context "user is refreshing repos" do
    it "will not enqueues repo sync job" do
      user = create(:user, refreshing_repos: true)
      stub_sign_in(user)
      allow(RepoSynchronizationJob).to receive(:perform_async)

      post :create

      expect(RepoSynchronizationJob).not_to have_received(:perform_async)
    end
  end

  context "user is not refreshing repos" do
    it "sets user to refreshing repos true and enqueues repo sync job" do
      user = create(:user)
      stub_sign_in(user)
      allow(RepoSynchronizationJob).to receive(:perform_async)

      post :create

      expect(user.reload).to be_refreshing_repos
      expect(RepoSynchronizationJob).
        to have_received(:perform_async).with(user.id)
    end
  end
end
