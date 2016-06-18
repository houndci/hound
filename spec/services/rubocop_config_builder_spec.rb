require "rubocop"
require "app/models/default_config_file"
require "app/services/rubocop_config_builder"
require "app/models/config/parser"

RSpec.describe RubocopConfigBuilder do
  describe "#config" do
    context "when there is no custom configuration" do
      it "returns the RuboCop defaults" do
        builder = RubocopConfigBuilder.new

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
        builder = RubocopConfigBuilder.new(content)

        config = builder.config

        expect(config["AllCops"]["DisabledByDefault"]).to be true
        expect(config["Style/Tab"]).to match disabled_rule
        expect(config["Style/VariableName"]).to match customer_override_rule
      end
    end

    context "when the custom configuration returns a type error from rubocop" do
      it "returns the default config" do
        content = { "this isn't parsible" => ["foo", "bar"] }
        builder = RubocopConfigBuilder.new(content)

        config = builder.config

        expect(config).to match rubocop_default_config
      end
    end
  end

  describe "#merge" do
    context "when the base and override configurations do not have overlap" do
      it "returns the contents of both combined" do
        base = {
          "AllCops" => {
            "DisabledByDefault" => true,
          },
        }
        overrides = {
          "Style/VariableName" => {
            "Enabled" => true,
          },
        }
        builder = RubocopConfigBuilder.new(base)

        merged_config = builder.merge(overrides)

        expect(merged_config["AllCops"]).
          to match hash_including base["AllCops"]
        expect(merged_config["Style/VariableName"]).
          to match hash_including overrides["Style/VariableName"]
      end
    end

    context "when the base and override configurations have overlap" do
      it "returns the contents of the overrides" do
        base = {
          "AllCops" => {
            "DisabledByDefault" => true,
          },
          "Style/VariableName" => {
            "Enabled" => true,
          },
        }
        overrides = {
          "AllCops" => {
            "DisabledByDefault" => false,
          },
        }
        builder = RubocopConfigBuilder.new(base)

        expect(builder.merge(overrides)["AllCops"]).
          to match hash_including("DisabledByDefault" => false)
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
