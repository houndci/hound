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
      api = double(:github_api, repos: [resource])
      allow(GithubApi).to receive(:new).and_return(api)
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
      api = double(:github_api, repos: [resource])
      allow(GithubApi).to receive(:new).and_return(api)
      user = create(:user)
      github_token = 'token'
      synchronization = RepoSynchronization.new(user, github_token)

      synchronization.start

      expect(user.repos.first).to be_in_organization
    end

    it 'replaces existing repos' do
      attributes = {
        full_name: 'user/newrepo',
        id: 456,
        private: false,
        owner: {
          type: 'User'
        }
      }
      resource = double(:resource, to_hash: attributes)
      github_token = 'token'
      membership = create(:membership)
      user = membership.user
      api = double(:github_api, repos: [resource])
      allow(GithubApi).to receive(:new).and_return(api)
      synchronization = RepoSynchronization.new(user, github_token)

      synchronization.start

      expect(GithubApi).to have_received(:new).with(github_token)
      expect(user.repos.size).to eq(1)
      expect(user.repos.first.full_github_name).to eq 'user/newrepo'
      expect(user.repos.first.github_id).to eq 456
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

      api = double(:github_api, repos: [resource])
      allow(GithubApi).to receive(:new).and_return(api)
      synchronization = RepoSynchronization.new(membership.user, github_token)

      synchronization.start

      expect(membership.user.repos.first.full_github_name).to eq repo_name
      expect(membership.user.repos.first.github_id).
        to eq membership.repo.github_id
    end

    describe "when a repo is deleted on github" do
      it "deactivates the repo" do
        user = create(:user)
        unchanged_repo = create_subscriber_repo_for(user)
        renamed_repo = create_subscriber_repo_for(user)
        deleted_repo = create_subscriber_repo_for(user)
        unchanged_repo_attributes = attributes_for(unchanged_repo)
        renamed_repo_attributes = attributes_for(renamed_repo)
        renamed_repo_attributes[:full_name] = "something/different"
        unchaged_resource =
          double(:resource, to_hash: unchanged_repo_attributes)
        renamed_resource = double(:resource, to_hash: renamed_repo_attributes)
        api = double(:github_api, repos: [unchaged_resource, renamed_resource])
        allow(GithubApi).to receive(:new).and_return(api)
        github_token = "token"
        synchronization = RepoSynchronization.new(user, github_token)
        allow(RepoSubscriber).to receive(:unsubscribe)

        synchronization.start
        deleted_repo.reload
        unchanged_repo.reload
        renamed_repo.reload

        expect(unchanged_repo).to be_active
        expect(RepoSubscriber).not_to have_received(:unsubscribe).
          with(unchanged_repo, user)
        expect(renamed_repo).to be_active
        expect(RepoSubscriber).not_to have_received(:unsubscribe).
          with(renamed_repo, user)
        expect(deleted_repo).not_to be_active
        expect(RepoSubscriber).to have_received(:unsubscribe).
          with(deleted_repo, user)
      end
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
        second_user = create(:user)
        api = double(:github_api, repos: [resource])
        allow(GithubApi).to receive(:new).and_return(api)
        synchronization = RepoSynchronization.new(second_user, github_token)

        synchronization.start

        expect(second_user.reload.repos.size).to eq(1)
      end
    end
  end

  def create_subscriber_repo_for(user)
    repo = create(:repo, private: true, active: true)
    create(:membership, repo: repo, user: user)
    create(:subscription, repo: repo, user: user)
    repo
  end

  def attributes_for(repo)
    {
      full_name: repo.full_github_name,
      id: repo.github_id,
      private: repo.private,
      owner: {
        type: "User"
      }
    }
  end
end
