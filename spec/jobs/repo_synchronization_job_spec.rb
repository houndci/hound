require 'spec_helper'

describe RepoSynchronizationJob do
  it 'is retryable' do
    expect(RepoSynchronizationJob).to be_a(Retryable)
  end

  describe '.before_enqueue' do
    it 'sets refreshing_repos to true' do
      user = create(:user)

      RepoSynchronizationJob.before_enqueue(user.id, 'token')

      expect(user.reload).to be_refreshing_repos
    end
  end

  describe '.perform' do
    it 'syncs repos and sets refreshing_repos to false' do
      user = create(:user, refreshing_repos: true)
      github_token = 'token'
      synchronization = double(:repo_synchronization, start: nil)
      RepoSynchronization.stub(new: synchronization)

      RepoSynchronizationJob.perform(user.id, github_token)

      expect(RepoSynchronization).to have_received(:new).with(
        user,
        github_token
      )
      expect(synchronization).to have_received(:start)
      expect(user.reload).not_to be_refreshing_repos
    end

    it 'retries when Resque::TermException is raised' do
      User.stub(:find).and_raise(Resque::TermException.new(1))
      Resque.stub(:enqueue)
      user_id = 'userid'
      github_token = 'token'

      RepoSynchronizationJob.perform(user_id, github_token)

      expect(Resque).to have_received(:enqueue).with(
        RepoSynchronizationJob,
        user_id,
        github_token
      )
    end
  end
end
