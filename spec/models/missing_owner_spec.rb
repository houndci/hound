require "app/models/missing_owner"

RSpec.describe MissingOwner do
  describe "#config_content" do
    it "is a missing Hound configuration" do
      expect(MissingOwner.new.config_content("anything")).to eq({})
    end
  end
end
