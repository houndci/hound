require "rails_helper"

describe HomeController do
  describe "#index" do
    context "when https is enabled" do
      context "and http is used" do
        it "redirects to https" do
          stub_const("Hound::HTTPS_ENABLED", "yes")

          get :index

          expect(response).to redirect_to(root_url(protocol: "https"))
        end
      end

      context "and https is used" do
        it "does not redirect" do
          stub_const("Hound::HTTPS_ENABLED", "yes")
          request.env["HTTPS"] = "on"

          get :index

          expect(response).not_to be_redirect
        end
      end
    end

    context "when https is disabled" do
      context "and http is used" do
        it "does not redirect" do
          get :index

          expect(response).not_to be_redirect
        end
      end
    end
  end
end
