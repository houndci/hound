require "app/models/user_token"

describe UserToken do
  describe "#token" do
    context "when user with a token is found" do
      it "returns user's token" do
        token = "foo_bar_token"
        user = instance_double("User", token: token)
        repo = instance_double("Repo", users_with_token: [user])
        user_token = UserToken.new(repo)

        expect(user_token.token).to eq token
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
      user = instance_double("User")
      repo = instance_double("Repo", users_with_token: [user])
      user_token = UserToken.new(repo)

      expect(user_token.user).to eq user
    end
  end
end
