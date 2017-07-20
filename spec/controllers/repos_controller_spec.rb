require "rails_helper"

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

    context "when current user is a bulk member of a repo" do
      it "returns 0 price in cents for that repo" do
        repo = create(
          :repo,
          in_organization: true,
          private: true,
          name: "yeehaw/wat",
        )
        create(:bulk_customer, org: "yeehaw")
        user = create(:user)
        user.repos << repo
        stub_sign_in(user)

        get :index, format: :json

        repos = JSON.parse(response.body)
        expect(repos.first["price_in_cents"]).to eq(0)
      end
    end
  end
end
