require "rubocop"
require "app/models/default_config_file"
require "app/services/ruby_config_builder"

RSpec.describe RubyConfigBuilder do
  context "when there is no custom configuration" do
    it "returns the Hound defaults" do
      builder = RubyConfigBuilder.new

      config = builder.config

      expect(config["Rails/ActionFilter"]).to match enabled_rule
      expect(config["Style/StringLiterals"]).to match hound_override_rule
      expect(config["Style/VariableName"]).to match rubocop_default_rule
    end
  end

  context "when owner is thoughtbot" do
    it "returns thoughbot specific configuration" do
      builder = RubyConfigBuilder.new({}, "thoughtbot")

      config = builder.config

      expect(config["Rails/ActionFilter"]).to match disabled_rule
      expect(config["Style/VariableName"]).to match rubocop_default_rule
    end
  end

  context "when custom configuration is provided" do
    it "returns merged config" do
      overrides = {
        "AllCops" => {
          "DisabledByDefault" => true,
        },
        "Style/VariableName" => {
          "EnforcedStyle" => "camel_case",
        },
      }
      builder = RubyConfigBuilder.new(overrides)

      config = builder.config

      expect(config["AllCops"]["DisabledByDefault"]).to be true
      expect(config["Style/Tab"]).to match disabled_rule
      expect(config["Style/StringLiterals"]).to match hound_override_rule
      expect(config["Style/VariableName"]).to match customer_override_rule
    end
  end

  def customer_override_rule
    hash_including("EnforcedStyle" => "camel_case", "Enabled" => true)
  end

  def hound_override_rule
    hash_including("EnforcedStyle" => "double_quotes", "Enabled" => true)
  end

  def rubocop_default_rule
    hash_including("EnforcedStyle" => "snake_case", "Enabled" => true)
  end

  def disabled_rule
    hash_including("Enabled" => false)
  end

  def enabled_rule
    hash_including("Enabled" => true)
  end
end
