require 'spec_helper'

describe RepoSynchronization do
  describe '#start' do
    it 'adds repos' do
      user = create(:user, github_token: 'token')
      api = double(:github_api, repos: [{name: 'Repo', full_name: 'org/repo', id: 123}])
      GithubApi.stub(new: api)
      synchronization = RepoSynchronization.new(user)

      synchronization.start

      expect(GithubApi).to have_received(:new).with(user.github_token)
      expect(user.repos).to have(1).item
    end

    it 'updates repos' do
      user = create(:user, github_token: 'token')
      repo = create(:repo, github_id: 123)
      user.repos << repo
      api = double(:github_api, repos: [{id: 123}])
      GithubApi.stub(new: api)
      synchronization = RepoSynchronization.new(user)

      synchronization.start

      expect(user).to have(1).repo
    end

    describe 'when a repo membership already exists' do
      it 'creates another membership' do
        repo = create(:repo)
        first_user = create(:user, github_token: 'token')
        second_user = create(:user, github_token: 'token')
        first_user.repos << repo
        api = double(
          :github_api,
          repos: [{id: repo.github_id, name: repo.name, full_name: repo.full_github_name}]
        )
        GithubApi.stub(new: api)
        synchronization = RepoSynchronization.new(second_user)

        synchronization.start

        expect(second_user.reload).to have(1).repos
      end
    end
  end
end
