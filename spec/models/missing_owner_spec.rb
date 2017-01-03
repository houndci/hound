require "spec_helper"
require "app/models/missing_owner"

RSpec.describe MissingOwner do
  describe "#hound_config" do
    it "is an empty hash" do
      expect(MissingOwner.new.hound_config).to eq({})
    end
  end
end
