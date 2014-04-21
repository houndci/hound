require 'spec_helper'

describe RepoSynchronization do
  describe '#start' do
    it 'replaces existing repos' do
      user = create(:user)
      github_token = 'githubtoken'
      existing_repo = create(:repo, github_id: 123)
      user.repos << existing_repo
      api = double(
        :github_api,
        repos: [
          { full_name: 'user/newrepo', id: 456 }
        ]
      )
      GithubApi.stub(new: api)
      synchronization = RepoSynchronization.new(user, github_token)

      synchronization.start

      expect(GithubApi).to have_received(:new).with(github_token)
      expect(user).to have(1).repo
      expect(user.repos.first.full_github_name).to eq 'user/newrepo'
    end

    describe 'when a repo membership already exists' do
      it 'creates another membership' do
        repo = create(:repo)
        first_user = create(:user)
        second_user = create(:user)
        github_token = 'githubtoken'
        first_user.repos << repo
        api = double(
          :github_api,
          repos: [{ id: repo.github_id, full_name: repo.full_github_name }]
        )
        GithubApi.stub(new: api)
        synchronization = RepoSynchronization.new(second_user, github_token)

        synchronization.start

        expect(second_user.reload).to have(1).repos
      end
    end
  end
end
