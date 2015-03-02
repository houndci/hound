require "spec_helper"

describe ReposController do
  describe "#index" do
    context "when current user is a member of a repo with missing information" do
      it "clears all memberships to allow for a forced reload" do
        repo = create(:repo, in_organization: nil, private: nil)
        user = create(:user, repos: [repo])
        stub_sign_in(user)

        get :index, format: :json

        expect(user.reload.repos.size).to eq(0)
      end
    end

    context "when current user is a member of a repo with no missing information" do
      it "clears all memberships to allow for a forced reload" do
        repo = create(:repo, in_organization: true, private: true)
        user = create(:user)
        user.repos << repo
        stub_sign_in(user)

        get :index, format: :json

        expect(user.repos.size).to eq(1)
      end
    end
  end

  context "when current user has duplicate memberships" do
    it "returns unique list of repos" do
      user = create(:user)
      repo = create(:repo)
      repo.users << user
      repo.users << user
      stub_sign_in(user)

      get :index, format: :json

      response_body = JSON.parse(response.body)
      expect(response_body.length).to eq(1)
    end
  end
end
