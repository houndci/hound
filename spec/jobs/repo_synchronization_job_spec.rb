require "rails_helper"

describe RepoSynchronizationJob do
  it "is retryable" do
    expect(RepoSynchronizationJob.new).to be_a(Retryable)
  end

  it "queue_as high" do
    expect(RepoSynchronizationJob.new.queue_name).to eq("high")
  end

  describe "perform" do
    it "syncs repos and sets refreshing_repos to false" do
      user = create(:user, refreshing_repos: false)
      synchronization = double(:repo_synchronization, start: nil)
      allow(RepoSynchronization).to receive(:new).and_return(synchronization)

      RepoSynchronizationJob.perform_now(user)

      expect(RepoSynchronization).to have_received(:new).with(user)
      expect(synchronization).to have_received(:start)
      expect(user.reload).not_to be_refreshing_repos
    end
  end
end
