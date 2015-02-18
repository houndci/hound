require "rails_helper"

describe DashboardsController, "#show" do
  context "when user is logged in" do
    it "loads dashboard" do
      stub_sign_in(create(:user))

      get :show

      expect(response).to render_template(:show)
    end
  end

  context "when user is not logged in" do
    it "redirects to home" do
      get :show

      expect(response).to redirect_to(root_path)
    end
  end
end
