require "rails_helper"

describe SessionsController do
  describe "#create" do
    context "with valid new user" do
      it "creates new user" do
        request.env["omniauth.auth"] = stub_oauth(
          username: "jimtom",
          email: "jimtom@example.com",
          token: "letmein",
        )
        allow(GitHubApi).to receive(:new).and_return(stub_github_api)
        session[:installation_id] = "101"

        post :create

        expect(User.count).to eq 1
        expect(User.first).to have_attributes(
          username: "jimtom",
          email: "jimtom@example.com",
          token: "letmein",
        )
      end
    end

    context "with invalid new user" do
      it "raises and does not save user" do
        request.env["omniauth.auth"] = stub_oauth(username: nil)

        expect { post :create }.to raise_error(
          ActiveRecord::RecordInvalid,
          "Validation failed: Username can't be blank",
        )
        expect(User.count).to be_zero
      end
    end

    context "with existing user" do
      it "updates email and token" do
        user = create(:user, username: "jim", email: "j@foo.com", token: "bar")
        request.env["omniauth.auth"] = stub_oauth(
          username: user.username,
          email: "jim@example.com",
          token: "letmein",
        )
        allow(GitHubApi).to receive(:new).and_return(stub_github_api)

        post :create

        user.reload
        expect(user.email).to eq "jim@example.com"
        expect(user.token).to eq "letmein"
        expect(user.reload).to have_attributes(
          email: "jim@example.com",
          token: "letmein",
        )
      end
    end
  end

  def stub_github_api
    instance_double("GitHubApi", scopes: "public_repo,user:email")
  end
end
