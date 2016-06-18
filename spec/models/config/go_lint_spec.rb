require "spec_helper"
require "app/models/config/base"
require "app/models/config/go_lint"
require "app/models/config/parser"

describe Config::GoLint do
  describe "#content" do
    it "returns an empty string" do
      hound_config = double("HoundConfig")
      config = Config::GoLint.new(hound_config)

      expect(config.content).to eq ""
    end
  end

  describe "#linter_names" do
    it "returns the names that the linter is accessible under" do
      hound_config = double("HoundConfig")
      config = Config::GoLint.new(hound_config)

      expect(config.linter_names).to match_array %w(go golint)
    end
  end
end
