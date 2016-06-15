require "rubocop"
require "app/models/default_config_file"
require "app/services/ruby_config_builder"
require "app/models/config/parser"

RSpec.describe RubyConfigBuilder do
  describe "#config" do
    context "when there is no custom configuration" do
      it "returns the RuboCop defaults" do
        builder = RubyConfigBuilder.new

        config = builder.config

        expect(config).to match rubocop_default_config
      end
    end

    context "when custom configuration is provided" do
      it "returns merged config" do
        content = {
          "AllCops" => {
            "DisabledByDefault" => true,
          },
          "Style/VariableName" => {
            "EnforcedStyle" => "camel_case",
          },
        }
        builder = RubyConfigBuilder.new(content)

        config = builder.config

        expect(config["AllCops"]["DisabledByDefault"]).to be true
        expect(config["Style/Tab"]).to match disabled_rule
        expect(config["Style/VariableName"]).to match customer_override_rule
      end
    end

    context "when the custom configuration returns a type error from rubocop" do
      it "returns the default config" do
        content = { "this isn't parsible" => ["foo", "bar"] }
        builder = RubyConfigBuilder.new(content)

        config = builder.config

        expect(config).to match rubocop_default_config
      end
    end
  end

  def customer_override_rule
    hash_including("EnforcedStyle" => "camel_case", "Enabled" => true)
  end

  def rubocop_default_config
    RuboCop::ConfigLoader.merge_with_default(RuboCop::Config.new, "")
  end

  def disabled_rule
    hash_including("Enabled" => false)
  end
end
