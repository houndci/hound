require "rails_helper"

describe HomeController, "#index" do
  context "when https is enabled" do
    context "and http is used" do
      it "redirects to https" do
        with_https_enabled do
          get :index

          expect(response).to redirect_to(root_url(protocol: "https"))
        end
      end
    end

    context "and https is used" do
      it "does not redirect" do
        with_https_enabled do
          request.env["HTTPS"] = "on"

          get :index

          expect(response).not_to be_redirect
        end
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
