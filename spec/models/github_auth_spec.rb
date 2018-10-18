require "octokit/error"
require "lib/github_api"
require "app/models/app_token"
require "app/models/github_auth"

RSpec.describe GitHubAuth do
  describe "#token" do
    context "when user with a token is found" do
      context "and the token can reach the repo" do
        it "returns user's token" do
          token = "foo_bar_token"
          user = instance_double("User", token: token)
          repo = stub_repo(users_with_token: [user])
          github_token = described_class.new(repo)
          stub_github(user.token)

          expect(github_token.token).to eq token
        end
      end

      context "and the token cannot reach the repo" do
        it "removes that user from repo and returns user with good token" do
          user_with_bad_token = instance_double("User", token: "abc123")
          user_with_good_token = instance_double("User", token: "def456")
          users = double(shuffle: [user_with_bad_token, user_with_good_token])
          repo = stub_repo(users_with_token: users)
          github_token = described_class.new(repo)
          stub_github("def456", statuses: [])
          unreachable_repo = stub_github("abc123")
          allow(unreachable_repo).to receive(:statuses).
            and_raise(Octokit::NotFound)

          expect(github_token.token).to eq user_with_good_token.token
          expect(repo).to have_received(:remove_membership).
            with(user_with_bad_token)
        end
      end
    end

    context "when no users for repo have tokens" do
      it "returns Hound's token" do
        stub_const("User", OpenStruct)
        stub_const("Hound::GITHUB_TOKEN", "hound-token")
        repo = stub_repo(users_with_token: [])
        github_token = described_class.new(repo)

        expect(github_token.token).to eq Hound::GITHUB_TOKEN
      end
    end

    context "when repo has an installation" do
      it "returns isntallation token" do
        user = instance_double("User", token: "anything")
        repo = stub_repo(users_with_token: [user], installation_id: 123)
        github_token = described_class.new(repo)
        app_token = instance_double("AppToken", generate: "app-token")
        stub_github(
          app_token.generate,
          create_installation_token: "installation-token",
        )
        allow(AppToken).to receive(:new).and_return(app_token)

        expect(github_token.token).to eq "installation-token"
      end
    end
  end

  describe "#user" do
    context "when repo has an installation" do
      it "returns nil" do
        user = instance_double("User", token: "anything")
        repo = stub_repo(users_with_token: [user], installation_id: 123)
        github_token = described_class.new(repo)
        stub_github(user.token)

        expect(github_token.user).to eq nil
      end
    end

    context "when repo does not have an installation" do
      it "returns the user that bears the current token" do
        user = instance_double("User", token: "abcd1")
        repo = stub_repo(users_with_token: [user])
        github_token = described_class.new(repo)
        stub_github(user.token)

        expect(github_token.user).to eq user
      end
    end
  end

  def stub_repo(attributes = {})
    default_attributes = {
      installation_id: nil,
      remove_membership: nil,
      users_with_token: [],
      name: "foo/bar",
    }

    instance_double("Repo", default_attributes.merge(attributes))
  end

  def stub_github(token, options = {})
    default_options = { statuses: [] }
    github_stub = instance_double("GitHubApi", default_options.merge(options))
    allow(GitHubApi).to receive(:new).with(token).and_return(github_stub)
    github_stub
  end
end
