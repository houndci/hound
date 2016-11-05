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
  end

  describe "#identify_hash" do
    it "includes user data" do
      user = create(:user)
      repo = create(:repo, :active, users: [user])

      identify_hash = identify_hash(user)

      expect(identify_hash).to eq(
        created: user.created_at,
        email: user.email,
        username: user.username,
        user_id: user.id,
        active_repo_ids: [repo.id],
      )
    end
  end

  describe "#intercom_hash" do
    it "includes user data" do
      user = build_stubbed(:user)

      expected_intercom_hash = OpenSSL::HMAC.hexdigest(
        "sha256",
        Hound::INTERCOM_API_SECRET,
        user.id.to_s,
      )

      expect(intercom_hash(user)).to eq(
        "Intercom" => { userHash: expected_intercom_hash },
      )
    end
  end
end
