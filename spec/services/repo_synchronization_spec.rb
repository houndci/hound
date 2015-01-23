require 'spec_helper'

describe RepoSynchronization do
  describe '#start' do
    it 'saves privacy flag' do
      attributes = {
        full_name: 'user/newrepo',
        id: 456,
        private: true,
        owner: {
          type: 'User'
        }
      }
      resource = double(:resource, to_hash: attributes)
      stub_api_repos(repos: [resource])
      user = create(:user)
      github_token = 'token'
      synchronization = RepoSynchronization.new(user, github_token)

      synchronization.start

      expect(user.repos.first).to be_private
    end

    it 'saves organization flag' do
      attributes = {
        full_name: 'user/newrepo',
        id: 456,
        private: false,
        owner: {
          type: 'Organization'
        }
      }
      resource = double(:resource, to_hash: attributes)
      stub_api_repos(repos: [resource])
      user = create(:user)
      github_token = 'token'
      synchronization = RepoSynchronization.new(user, github_token)

      synchronization.start

      expect(user.repos.first).to be_in_organization
    end

    it 'renames an existing repo if updated on github' do
      membership = create(:membership)
      repo_name = 'user/newrepo'
      attributes = {
        full_name: repo_name,
        id: membership.repo.github_id,
        private: true,
        owner: {
          type: 'User'
        }
      }
      resource = double(:resource, to_hash: attributes)
      github_token = 'githubtoken'
      stub_api_repos(repos: [resource])
      synchronization = RepoSynchronization.new(membership.user, github_token)

      synchronization.start

      expect(membership.user.repos.first.full_github_name).to eq repo_name
      expect(membership.user.repos.first.github_id).
        to eq membership.repo.github_id
    end

    describe 'when a repo membership already exists' do
      it 'creates another membership' do
        first_membership = create(:membership)
        repo = first_membership.repo
        attributes = {
          full_name: repo.full_github_name,
          id: repo.github_id,
          private: true,
          owner: {
            type: 'User'
          }
        }
        resource = double(:resource, to_hash: attributes)
        github_token = 'githubtoken'
        stub_api_repos(repos: [resource])
        second_user = create(:user)
        synchronization = RepoSynchronization.new(second_user, github_token)

        synchronization.start

        expect(second_user.reload.repos.size).to eq(1)
      end
    end

    describe "when a user no longer has access to a repo" do
      it "deactivates a repo when there are no other memberships" do
        repo = create(:repo, :active)
        repo.memberships.destroy_all
        membership = create(:membership, repo: repo)
        github_token = "githubtoken"
        stub_api_repos(repos: [])
        synchronization = RepoSynchronization.new(membership.user, github_token)

        synchronization.start
        repo.reload

        expect(repo).not_to be_active
      end

      it "does not deactivate a repo when there are other memberships" do
        repo = create(:membership).repo
        repo.update(active: true)
        membership = create(:membership, repo: repo)
        github_token = "githubtoken"
        stub_api_repos(repos: [])
        synchronization = RepoSynchronization.new(membership.user, github_token)

        synchronization.start
        repo.reload

        expect(repo).to be_active
      end

      it "destroys the users membership when a repo gets deactivated" do
        repo = create(:repo, :active)
        repo.memberships.destroy_all
        membership = create(:membership, repo: repo)
        user = membership.user
        github_token = "githubtoken"
        stub_api_repos(repos: [])
        synchronization = RepoSynchronization.new(membership.user, github_token)

        synchronization.start

        expect(user.memberships).to be_empty
      end

      it "unsubscribes the user when a repo gets deactivated" do
        repo = create(:repo, :active)
        subscription = create(:subscription, repo: repo)
        user = subscription.user
        repo.memberships.destroy_all
        create(:membership, repo: repo, user: user)
        github_token = "githubtoken"
        stub_api_repos(repos: [])
        allow(RepoSubscriber).to receive(:unsubscribe)
        synchronization = RepoSynchronization.new(user, github_token)

        synchronization.start

        expect(RepoSubscriber).to have_received(:unsubscribe).with(repo, user)
      end
    end
  end

  def stub_api_repos(attrs)
    api = double(:github_api, attrs)
    allow(GithubApi).to receive(:new).and_return(api)
  end
end
