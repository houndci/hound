require "rails_helper"

describe RepoSynchronization do
  describe "#start" do
    it "saves privacy flag" do
      stub_github_api_repos(repo_id: 456, repo_name: "user/newrepo")
      user = create(:user)
      synchronization = RepoSynchronization.new(user)

      synchronization.start

      expect(user.reload.repos.first).to be_private
    end

    it "saves organization flag" do
      stub_github_api_repos(repo_id: 456, repo_name: "user/newrepo")
      user = create(:user)
      synchronization = RepoSynchronization.new(user)

      synchronization.start

      expect(user.reload.repos.first).to be_in_organization
    end

    context "when there is an 'ActiveRecord::RecordNotUnique' exception" do
      it "finishes the synchronization" do
        repo = stub_github_api_repos(repo_id: 456, repo_name: "user/newrepo")
        user = create(:user)
        synchronization = RepoSynchronization.new(user)
        allow(synchronization).to receive(:repo_attributes).
          and_raise(ActiveRecord::RecordNotUnique)

        result = synchronization.start

        expect(result).to eq [repo]
      end
    end

    context "when the user is a repo admin" do
      it "the memberships admin flag is true" do
        stub_github_api_repos(
          repo_id: 456,
          repo_name: "user/newrepo",
          admin: true,
        )
        user = create(:user)
        synchronization = RepoSynchronization.new(user)

        synchronization.start

        expect(user.memberships.first).to be_admin
      end
    end

    context "when the user is not a repo admin" do
      it "the membership admin flag is false" do
        stub_github_api_repos(
          repo_id: 456,
          repo_name: "user/newrepo",
          admin: false,
        )
        user = create(:user)
        synchronization = RepoSynchronization.new(user)

        synchronization.start

        expect(user.memberships.first).not_to be_admin
      end
    end

    it "replaces existing repos" do
      stub_github_api_repos(repo_id: 456, repo_name: "user/newrepo")
      membership = create(:membership)
      user = membership.user
      synchronization = RepoSynchronization.new(user)

      synchronization.start

      user.reload
      expect(user.repos.size).to eq(1)
      expect(user.repos.first.name).to eq "user/newrepo"
      expect(user.repos.first.github_id).to eq 456
    end

    context "when repo was renamed to an existing repo" do
      it "updates the repo names" do
        user = create(:user)
        repo1 = create(:repo, name: "main")
        repo2 = create(:repo, name: "backup")
        create(:membership, user: user, repo: repo1)
        create(:membership, user: user, repo: repo2)
        github_repo1 = build_github_repo(id: repo1.github_id, name: "backup")
        github_repo2 = build_github_repo(id: repo2.github_id, name: "site")
        api = instance_double("GithubApi", repos: [github_repo1, github_repo2])
        allow(GithubApi).to receive(:new).and_return(api)
        synchronization = RepoSynchronization.new(user)

        synchronization.start

        user.reload
        expect(user.repos.pluck(:id, :name)).to match_array [
          [repo1.id, "backup"],
          [repo2.id, "site"],
        ]
      end
    end

    context "when a repo membership already exists" do
      it "creates another membership" do
        first_membership = create(:membership)
        repo = first_membership.repo
        stub_github_api_repos(repo_id: repo.github_id, repo_name: repo.name)
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
          repo_github_id = 321
          stub_github_api_repos(
            repo_id: repo_github_id,
            repo_name: "foo/bar",
            owner_id: owner_github_id,
          )
          synchronization = RepoSynchronization.new(user)

          synchronization.start

          owner = Owner.find_by(github_id: owner_github_id)
          expect(owner.name).to eq("thoughtbot")
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
            repo_name: "foo/bar",
            owner_id: owner.github_id,
          )
          synchronization = RepoSynchronization.new(user)

          synchronization.start

          owner = Owner.find_by(github_id: owner.github_id)
          expect(owner.repos.map(&:github_id)).to eq([repo_github_id])
        end
      end
    end

    def stub_github_api_repos(repo_name:, repo_id:, owner_id: 1, admin: false)
      repo = build_github_repo(id: repo_id, name: repo_name)
      repo[:owner][:id] = owner_id
      repo[:permissions][:admin] = admin

      api = double("GithubApi", repos: [repo])
      allow(GithubApi).to receive(:new).and_return(api)

      repo
    end

    def build_github_repo(id:, name:)
      {
        full_name: name,
        id: id,
        private: true,
        owner: {
          id: 123,
          login: "thoughtbot",
          type: "Organization",
        },
        permissions: {
          admin: false,
        },
      }
    end
  end
end
