require "spec_helper"
require "app/models/missing_owner"

RSpec.describe MissingOwner do
  describe "#hound_config" do
    it "is a missing Hound configuration" do
      expect(MissingOwner.new.hound_config.content).to eq({})
    end
  end
end
