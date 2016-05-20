require "rails_helper"

describe AnalyticsHelper do
  describe "#analytics?" do
    context "when SEGMENT_KEY is present" do
      it "returns true" do
        stub_const("Hound::SEGMENT_KEY", "anything")

        expect(analytics?).to eq true
      end
    end

    context "when SEGMENT_KEY is not present" do
      it "returns false" do
        stub_const("Hound::SEGMENT_KEY", "")

        expect(analytics?).to eq false
      end
    end

    describe "#identify_hash" do
      it "includes user data" do
        user = create(:user)
        repo = create(:repo, :active, users: [user])

        identify_hash = identify_hash(user)

        expect(identify_hash).to eq(
          created: user.created_at,
          email: user.email_address,
          username: user.github_username,
          user_id: user.id,
          active_repo_ids: [repo.id],
        )
      end
    end
  end
end
