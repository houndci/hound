# frozen_string_literal: true
require "rails_helper"

describe "GET /masqerades?username=:username" do
  context "as an admin" do
    it "redirects to repos as the maqueraded user" do
      admin = create(:user, username: "admin", token: "admin-token")
      user = create(:user, username: "us3rn4me", token: "user-token")
      stub_const("Hound::ADMIN_GITHUB_USERNAMES", ["admin"])

      sign_in_as(admin)
      get admin_masquerade_path(username: user.username)

      expect(response).to redirect_to(repos_path)
      follow_redirect!
      expect(response.body).to include("us3rn4me")
      expect(session[:masqueraded_user_id]).to eq(user.id)
      expect(session[:remember_token]).to eq(admin.remember_token)
    end
  end

  context "as a non-admin user" do
    it "redirects to root and does not masquerade as user" do
      non_admin = create(:user, token: "non-admin-token")
      user = create(:user, username: "us3rn4me", token: "user-token")

      sign_in_as(non_admin)
      get admin_masquerade_path(username: user.username)

      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).not_to include("us3rn4me")
      expect(session[:masqueraded_user_id]).to be_nil
      expect(session[:remember_token]).to eq(non_admin.remember_token)
    end
  end

  def sign_in_as(user)
    stub_oauth(username: user.username, email: user.email, token: user.token)
    post "/auth/github"
    follow_redirect!
  end
end
