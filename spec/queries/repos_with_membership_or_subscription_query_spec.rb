require "rails_helper"

describe ReposWithMembershipOrSubscriptionQuery do
  describe "#call" do
    context "when user is not a member of a repo but has a subscription" do
      it "includes the orphaned repo" do
        subscribed_repo = create(:repo, private: true)
        user = create(:user)
        create(:subscription, user: user, repo: subscribed_repo)

        repos = ReposWithMembershipOrSubscriptionQuery.new(user).call

        expect(repos).to include(subscribed_repo)
      end
    end

    it "does not duplicate subscribed repos" do
      user = create(:user)
      subscribed_repo = create(:repo, private: true)
      user.repos << subscribed_repo
      create(:subscription, user: user, repo: subscribed_repo)

      repos = ReposWithMembershipOrSubscriptionQuery.new(user).call

      expect(repos).to eq [subscribed_repo]
    end
  end
end
