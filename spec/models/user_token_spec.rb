require "octokit/error"
require "lib/github_api"
require "app/models/user_token"

describe UserToken do
  describe "#token" do
    context "when user with a token is found" do
      context "and the token can reach the repo" do
        it "returns user's token" do
          token = "foo_bar_token"
          user = instance_double("User", token: token)
          repo = instance_double(
            "Repo",
            users_with_token: [user],
            name: "foo/bar",
          )
          user_token = UserToken.new(repo)
          stub_github(user.token)

          expect(user_token.token).to eq token
        end
      end

      context "and the token cannot reach the repo" do
        it "removes that user from repo and returns user with good token" do
          user_with_bad_token = instance_double("User", token: "abc123")
          user_with_good_token = instance_double("User", token: "def456")
          repo = instance_double(
            "Repo",
            name: "thoughtbot/guides",
            remove_membership: nil,
            users_with_token:
              double(shuffle: [user_with_bad_token, user_with_good_token]),
          )
          user_token = UserToken.new(repo)
          stub_github("abc123", repository?: false)
          stub_github("def456", repository?: true)

          expect(user_token.token).to eq user_with_good_token.token
          expect(repo).to have_received(:remove_membership).
            with(user_with_bad_token)
        end
      end
    end

    context "when no users for repo have tokens" do
      it "returns Hound's token" do
        stub_const("User", OpenStruct)
        stub_const("Hound::GITHUB_TOKEN", "sometoken")
        repo = instance_double("Repo", users_with_token: [])
        user_token = UserToken.new(repo)

        expect(user_token.token).to eq Hound::GITHUB_TOKEN
      end
    end
  end

  describe "#user" do
    it "returns the user that bears the current token" do
      user = instance_double("User", token: "abcd1")
      repo = instance_double("Repo", users_with_token: [user], name: "foo/bar")
      user_token = UserToken.new(repo)
      stub_github(user.token)

      expect(user_token.user).to eq user
    end
  end

  def stub_github(token, options = {})
    default_options = { repository?: true }
    github_stub = instance_double("GithubApi", default_options.merge(options))
    allow(GithubApi).to receive(:new).with(token).and_return(github_stub)
    github_stub
  end
end
