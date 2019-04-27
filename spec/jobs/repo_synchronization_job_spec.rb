require "rails_helper"

RSpec.describe RepoSynchronizationJob do
  it "queues as high" do
    expect(RepoSynchronizationJob.queue).to eq(:high)
  end

  describe "perform" do
    it "syncs repos and sets refreshing_repos to false" do
      user = create(:user, refreshing_repos: false)
      synchronization = double(:repo_synchronization, start: nil)
      allow(RepoSynchronization).to receive(:new).and_return(synchronization)

      RepoSynchronizationJob.perform_async(user.id)

      expect(RepoSynchronization).to have_received(:new).with(user)
      expect(synchronization).to have_received(:start)
      expect(user.reload).not_to be_refreshing_repos
    end
  end
end
