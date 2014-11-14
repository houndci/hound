require "spec_helper"

describe SessionsController do
  describe "#create" do
    context "with valid new user" do
      it "creates new user" do
        request.env["omniauth.auth"] = stub_oauth(
          username: "jimtom",
          email: "jimtom@example.com",
          name: "Jim Tom",
        )

        expect { post :create }.to change { User.count }.by(1)
        user = User.last
        expect(user.github_username).to eq "jimtom"
        expect(user.email_address).to eq "jimtom@example.com"
        expect(user.name).to eq "Jim Tom"
      end
    end

    context "with invalid new user" do
      it "raises and does not save user" do
        request.env["omniauth.auth"] = stub_oauth(username: nil)

        expect { post :create }.to raise_error
        expect(User.count).to be_zero
      end
    end
  end
end
