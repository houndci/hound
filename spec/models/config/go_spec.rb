require "spec_helper"
require "app/models/config/base"
require "app/models/config/go"

describe Config::Go do
  describe "#content" do
    it "returns an empty string" do
      hound_config = double("HoundConfig")
      config = Config::Go.new(hound_config, "go")

      expect(config.content).to eq ""
    end
  end
end
