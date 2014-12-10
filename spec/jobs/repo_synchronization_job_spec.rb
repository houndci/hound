require "spec_helper"

describe RepoSynchronizationJob do
  it "is retryable" do
    expect(RepoSynchronizationJob).to be_a(Retryable)
  end

  describe ".before_enqueue" do
    it "sets refreshing_repos to true" do
      user = create(:user)

      RepoSynchronizationJob.before_enqueue(user.id, "token")

      expect(user.reload).to be_refreshing_repos
    end

    it "returns true if not refreshing" do
      user = create(:user)

      expect(RepoSynchronizationJob.before_enqueue(user.id, "token")).
        to be true
    end

    it "returns false if already refreshing" do
      user = create(:user, refreshing_repos: true)

      expect(RepoSynchronizationJob.before_enqueue(user.id, "token")).
        to be false
    end
  end

  describe ".perform" do
    it "syncs repos and sets refreshing_repos to false" do
      user = create(:user, refreshing_repos: true)
      github_token = "token"
      synchronization = double(:repo_synchronization, start: nil)
      allow(RepoSynchronization).to receive(:new).and_return(synchronization)

      RepoSynchronizationJob.perform(user.id, github_token)

      expect(RepoSynchronization).to have_received(:new).with(
        user,
        github_token
      )
      expect(synchronization).to have_received(:start)
      expect(user.reload).not_to be_refreshing_repos
    end

    it "retries when Resque::TermException is raised" do
      allow(User).to receive(:find).and_raise(Resque::TermException.new(1))
      allow(Resque).to receive(:enqueue)
      user_id = "userid"
      github_token = "token"

      RepoSynchronizationJob.perform(user_id, github_token)

      expect(Resque).to have_received(:enqueue).with(
        RepoSynchronizationJob,
        user_id,
        github_token
      )
    end
  end
end
