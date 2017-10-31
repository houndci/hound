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
          refreshing_repos: user.refreshing_repos,
          subscribed_repo_count: 0,
          plan_max: 0,
          username: user.username,
          owners: [],
        }.to_json,
      )
    end
  end
end
