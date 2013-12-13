require 'spec_helper'

describe RepoSynchronization do
  describe '#start' do
    it 'adds repos' do
      user = create(:user, github_token: 'token')
      api = double(:github_api, repos: [{name: 'Repo'}])
      GithubApi.stub(new: api)
      synchronization = RepoSynchronization.new(user)

      synchronization.start

      expect(GithubApi).to have_received(:new).with(user.github_token)
      expect(user.repos).to have(1).item
    end

    it 'updates repos' do
      user = create(:user, github_token: 'token')
      repo = create(:repo, github_id: 123)
      create(:membership, repo: repo, user: user)
      api = double(:github_api, repos: [{id: 123}])
      GithubApi.stub(new: api)
      synchronization = RepoSynchronization.new(user)

      synchronization.start

      expect(user).to have(1).repo
    end
  end
end
