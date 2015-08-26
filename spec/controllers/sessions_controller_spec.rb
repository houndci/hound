require "rails_helper"

describe SessionsController do
  describe "#create" do
    context "with valid new user" do
      it "creates new user" do
        stub_scopes_request(token: "letmein")
        request.env["omniauth.auth"] = stub_oauth(
          username: "jimtom",
          email: "jimtom@example.com",
          token: "letmein",
        )

        expect { post :create }.to change { User.count }.by(1)
        user = User.last
        expect(user.github_username).to eq "jimtom"
        expect(user.email_address).to eq "jimtom@example.com"
      end
    end

    context "with invalid new user" do
      it "raises and does not save user" do
        request.env["omniauth.auth"] = stub_oauth(username: nil)

        expect do
          post :create
        end.to raise_error(
          ActiveRecord::RecordInvalid,
          "Validation failed: Github username can't be blank",
        )
        expect(User.count).to be_zero
      end
    end
  end
end
