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
end
