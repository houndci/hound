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

        expect { post :create }.to change { User.count }.by(1)
        user = User.last
        expect(user.username).to eq "jimtom"
        expect(user.email).to eq "jimtom@example.com"
        expect(user.token).to eq "letmein"
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
      it "updates the token and email" do
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
      end
    end
  end

  def stub_github_api
    instance_double("GitHubApi", scopes: "public_repo,user:email")
  end
end
