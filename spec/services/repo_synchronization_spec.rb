require 'spec_helper'

describe RepoSynchronization do
  describe '#start' do
    it 'replaces existing repos' do
      github_token = 'githubtoken'
      membership = create(:membership)
      user = membership.user

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
      expect(user.repos.first.github_id).to eq 456
    end

    it 'renames an existing repo if updated on github' do
      github_token = 'githubtoken'
      membership = create(:membership)

      api = double(
        :github_api,
        repos: [
          {
            name: 'New Name',
            full_name: 'user/newname',
            id: membership.repo.github_id
          }
        ]
      )
      GithubApi.stub(new: api)
      synchronization = RepoSynchronization.new(membership.user, github_token)

      synchronization.start

      expect(membership.user.repos.first.full_github_name).to eq 'user/newname'
      expect(membership.user.repos.first.github_id).
        to eq membership.repo.github_id
    end

    describe 'when a repo membership already exists' do
      it 'creates another membership' do
        github_token = 'githubtoken'
        first_membership = create(:membership)
        repo = first_membership.repo
        second_user = create(:user)
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
