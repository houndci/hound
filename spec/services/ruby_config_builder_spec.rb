require "rubocop"
require "app/models/default_config_file"
require "app/services/ruby_config_builder"

RSpec.describe RubyConfigBuilder do
  context "when there is no custom configuration" do
    subject(:builder) { described_class.new }

    it "returns the Hound defaults", aggregate_failures: true do
      config = builder.config

      expect(config["Style/StringLiterals"]).to match hound_override_rule
      expect(config["Style/VariableName"]).to match rubocop_default_rule
    end
  end

  context "when custom configuration is provided" do
    it "returns merged config" do
      overrides = {
        "Style/VariableName" => {
          "EnforcedStyle" => "camel_case",
        },
      }
      builder = RubyConfigBuilder.new(overrides)

      config = builder.config

      expect(config["Style/StringLiterals"]).to match hound_override_rule
      expect(config["Style/VariableName"]).to match customer_override_rule
    end
  end

  def customer_override_rule
    hash_including("EnforcedStyle" => "camel_case")
  end

  def hound_override_rule
    hash_including("EnforcedStyle" => "double_quotes")
  end

  def rubocop_default_rule
    hash_including("EnforcedStyle" => "snake_case")
  end
end
