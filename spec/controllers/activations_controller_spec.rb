require "rails_helper"

describe ActivationsController, "#create" do
  context "when activation succeeds" do
    it "returns successful response" do
      membership = create(:membership)
      repo = membership.repo
      stub_sign_in(membership.user)

      post :create, params: { repo_id: repo.id }, format: :json

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)).to eq(
        "id" => repo.id,
        "active" => true,
        "admin" => false,
        "github_id" => repo.github_id,
        "name" => repo.name,
        "private" => false,
        "stripe_subscription_id" => nil,
        "owner" => {
          "id" => repo.owner.id,
          "created_at" => repo.owner.created_at.iso8601(3),
          "updated_at" => repo.owner.updated_at.iso8601(3),
          "github_id" => repo.owner.github_id,
          "name" => repo.owner.name,
          "organization" => false,
          "config_enabled" => false,
          "config_repo" => nil,
          "whitelisted" => false,
          "marketplace_plan_id" => nil,
          "stripe_subscription_id" => nil,
        },
      )
    end
  end

  context "when repo is not public" do
    it "does not activate" do
      repo = create(:repo, private: true)
      user = create(:user)
      user.repos << repo
      stub_sign_in(user)

      expect { post :create, params: { repo_id: repo.id }, format: :json }.
        to raise_error(ActivationsController::CannotActivatePaidRepo)
    end
  end
end
