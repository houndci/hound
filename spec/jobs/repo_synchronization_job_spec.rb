require "spec_helper"

describe RepoSynchronizationJob do
  it "is retryable" do
    expect(RepoSynchronizationJob).to be_a(Retryable)
  end

  it "queue_as high" do
    expect(RepoSynchronizationJob.new.queue_name).to eq("high")
  end

  describe "before_perform" do
    it "sets refreshing_repos to true" do
      user = double(
        "User",
        id: 1,
        repos: [],
        update_attribute: true
      )
      allow(User).to receive(:set_refreshing_repos).with(user.id)
      allow(User).to receive(:find).and_return(user)

      synchronization = double(
        "RepoSynchronization",
        start: nil
      )
      allow(RepoSynchronization).to receive(:new).and_return(synchronization)

      RepoSynchronizationJob.perform_now(user.id, "token")

      expect(User).to have_received(:set_refreshing_repos).with(user.id)
    end
  end

  describe "perform" do
    it "will not refresh repo if already refreshing" do
      user = create(:user, refreshing_repos: true)

      synchronization = double(
        "RepoSynchronization",
        start: nil
      )
      allow(RepoSynchronization).to receive(:new).and_return(synchronization)

      RepoSynchronizationJob.perform_now(user.id, "token")

      expect(RepoSynchronization).not_to have_received(:new)
    end

    it "syncs repos and sets refreshing_repos to false" do
      user = create(:user, refreshing_repos: false)
      github_token = "token"
      synchronization = double(:repo_synchronization, start: nil)
      allow(RepoSynchronization).to receive(:new).and_return(synchronization)

      RepoSynchronizationJob.perform_now(user.id, github_token)

      expect(RepoSynchronization).to have_received(:new).with(
        user,
        github_token
      )
      expect(synchronization).to have_received(:start)
      expect(user.reload).not_to be_refreshing_repos
    end

    it "retries when Resque::TermException is raised" do
      allow(User).to receive(:find).and_raise(Resque::TermException.new(1))
      allow(User).to receive(:set_refreshing_repos).and_return(true)
      user_id = "userid"
      github_token = "token"
      allow(RepoSynchronizationJob.queue_adapter).to receive(:enqueue)

      job = RepoSynchronizationJob.perform_now(user_id, github_token)

      expect(RepoSynchronizationJob.queue_adapter).to have_received(:enqueue).with(job)
    end
  end
end
