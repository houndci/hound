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
      github_token = "token"
      synchronization = double(:repo_synchronization, start: nil)
      allow(RepoSynchronization).to receive(:new).and_return(synchronization)

      RepoSynchronizationJob.perform_now(user, github_token)

      expect(RepoSynchronization).to have_received(:new).with(
        user,
        github_token
      )
      expect(synchronization).to have_received(:start)
      expect(user.reload).not_to be_refreshing_repos
    end

    it "retries when Resque::TermException is raised" do
      allow(RepoSynchronization).to receive(:new).and_raise(Resque::TermException.new(1))
      user = build_stubbed(:user)
      github_token = "token"
      allow(RepoSynchronizationJob.queue_adapter).to receive(:enqueue)

      job = RepoSynchronizationJob.new(user, github_token)
      job.perform_now

      expect(RepoSynchronizationJob.queue_adapter).
        to have_received(:enqueue).with(job)
    end
  end
end
