require "rails_helper"

describe RepoSynchronization do
  describe "#start" do
    it "saves privacy flag" do
      stub_github_api_repos(
        repo_id: 456,
        owner_id: 1,
        owner_name: "thoughtbot",
        repo_name: "user/newrepo"
      )
      user = create(:user)
      synchronization = RepoSynchronization.new(user)

      synchronization.start

      expect(user.repos.first).to be_private
    end

    it "saves organization flag" do
      stub_github_api_repos(
        repo_id: 456,
        owner_id: 1,
        owner_name: "thoughtbot",
        private_repo: false,
        repo_name: "user/newrepo"
      )
      user = create(:user)
      synchronization = RepoSynchronization.new(user)

      synchronization.start

      expect(user.repos.first).to be_in_organization
    end

    it "replaces existing repos" do
      stub_github_api_repos(
        repo_id: 456,
        owner_id: 1,
        owner_name: "thoughtbot",
        private_repo: false,
        repo_name: "user/newrepo"
      )
      membership = create(:membership)
      user = membership.user
      synchronization = RepoSynchronization.new(user)

      synchronization.start

      expect(user.repos.size).to eq(1)
      expect(user.repos.first.full_github_name).to eq "user/newrepo"
      expect(user.repos.first.github_id).to eq 456
    end

    it "renames an existing repo if updated on github" do
      membership = create(:membership)
      repo_name = "user/newrepo"
      stub_github_api_repos(
        repo_id: membership.repo.github_id,
        owner_id: 1,
        owner_name: "thoughtbot",
        repo_name: repo_name
      )
      synchronization = RepoSynchronization.new(membership.user)

      synchronization.start

      expect(membership.user.repos.first.full_github_name).to eq repo_name
      expect(membership.user.repos.first.github_id).
        to eq membership.repo.github_id
    end

    describe "when a repo membership already exists" do
      it "creates another membership" do
        first_membership = create(:membership)
        repo = first_membership.repo
        stub_github_api_repos(
          repo_id: repo.github_id,
          owner_id: 1,
          owner_name: "thoughtbot"
        )
        second_user = create(:user)
        synchronization = RepoSynchronization.new(second_user)

        synchronization.start

        expect(second_user.reload.repos.size).to eq(1)
      end
    end

    describe "repo owners" do
      context "when the owner doesn't exist" do
        it "creates and associates an owner to the repo" do
          user = create(:user)
          owner_github_id = 1234
          owner_name = "thoughtbot"
          repo_github_id = 321
          stub_github_api_repos(
            repo_id: repo_github_id,
            owner_id: owner_github_id,
            owner_name: owner_name
          )
          synchronization = RepoSynchronization.new(user)

          synchronization.start

          owner = Owner.find_by(github_id: owner_github_id)
          expect(owner.name).to eq(owner_name)
          expect(owner.repos.map(&:github_id)).to eq([repo_github_id])
        end
      end

      context "when the owner exists" do
        it "updates and associates an owner to the repo" do
          owner = create(:owner)
          user = create(:user)
          repo_github_id = 321
          stub_github_api_repos(
            repo_id: repo_github_id,
            owner_id: owner.github_id,
            owner_name: owner.name
          )
          synchronization = RepoSynchronization.new(user)

          synchronization.start

          owner = Owner.find_by(github_id: owner.github_id)
          expect(owner.repos.map(&:github_id)).to eq([repo_github_id])
        end
      end
    end

    def stub_github_api_repos(
      repo_id:,
      owner_id:,
      owner_name:,
      private_repo: true,
      repo_name: "thoughtbot/newrepo"
    )
      attributes = {
        full_name: repo_name,
        id: repo_id,
        private: private_repo,
        owner: {
          id: owner_id,
          login: owner_name,
          type: "Organization",
        }
      }
      resource = double(:resource, to_hash: attributes)
      api = double("GithubApi", repos: [resource])
      allow(GithubApi).to receive(:new).and_return(api)
    end
  end
end
