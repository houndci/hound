require "rails_helper"

RSpec.describe RepoSynchronization do
  describe "#start" do
    it "saves privacy flag" do
      stub_github_api(repo_id: 456, repo_name: "user/newrepo")
      user = create(:user)
      synchronization = RepoSynchronization.new(user)

      synchronization.start

      expect(user.reload.repos.first).to be_private
    end

    it "replaces existing repos" do
      stub_github_api(repo_id: 456, repo_name: "user/newrepo")
      membership = create(:membership)
      user = membership.user
      synchronization = RepoSynchronization.new(user)

      synchronization.start

      user.reload
      expect(user.repos.size).to eq(1)
      expect(user.repos.first.name).to eq "user/newrepo"
      expect(user.repos.first.github_id).to eq 456
    end

    context "when there is an 'ActiveRecord::RecordNotUnique' exception" do
      it "handles the exception" do
        stub_github_api(repo_id: 456, repo_name: "user/newrepo")
        user = create(:user)
        synchronization = RepoSynchronization.new(user)
        allow(CreateRepo).to receive(:call).
          and_raise(ActiveRecord::RecordNotUnique)

        expect { synchronization.start }.not_to raise_error
      end
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
        api = stub_github_api(repo_id: nil, repo_name: nil)
        allow(api).to receive(:installation_repos).
          and_return([github_repo1, github_repo2])
        synchronization = RepoSynchronization.new(user)

        synchronization.start

        expect(user.reload.repos).to match_array [
          an_object_having_attributes(
            id: repo1.id,
            github_id: repo1.github_id,
            name: github_repo1[:full_name],
          ),
          an_object_having_attributes(
            id: repo2.id,
            github_id: repo2.github_id,
            name: github_repo2[:full_name],
          ),
        ]
      end
    end

    context "when a repo membership already exists" do
      it "creates another membership" do
        first_membership = create(:membership)
        repo = first_membership.repo
        stub_github_api(repo_id: repo.github_id, repo_name: repo.name)
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
          stub_github_api(
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
          stub_github_api(
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

    def stub_github_api(repo_name:, repo_id:, owner_id: 123)
      repo = build_github_repo(id: repo_id, name: repo_name, owner_id: owner_id)
      api = instance_double(
        "GitHubApi",
        installation_repos: [repo],
        user_installations: [OpenStruct.new(id: 10001)],
        create_installation_token: "some-token",
      )
      allow(GitHubApi).to receive(:new).and_return(api)
      api
    end

    def build_github_repo(id:, name:, owner_id: 123)
      {
        full_name: name,
        id: id,
        private: true,
        owner: {
          id: owner_id,
          login: "thoughtbot",
          type: "Organization",
        },
      }
    end
  end
end
