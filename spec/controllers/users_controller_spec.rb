require "rails_helper"

describe UsersController do
  describe "#show" do
    it "returns current user in json" do
      user = create(:user)
      stub_sign_in(user)

      get :show, format: :json

      expect(response.body).to eq(
        {
          id: user.id,
          github_username: user.github_username,
          card_exists: false,
          refreshing_repos: user.refreshing_repos
        }.to_json
      )
    end
  end
end
