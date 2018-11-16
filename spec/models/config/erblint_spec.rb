require "app/models/missing_owner"
require "app/models/config_content"
require "app/models/config/parser"
require "app/models/config/serializer"
require "app/models/config/base"
require "app/models/config/erblint"

RSpec.describe Config::Erblint do
  describe "#content" do
    it "returns merged configuration" do
      raw_config = <<~YAML
        linters:
          DeprecatedClasses:
            enabled: true
      YAML
      owner_config = {
        "linters" => {
          "FinalNewline" => {
            "enabled" => true,
          },
        },
      }
      owner = instance_double("Owner", config_content: owner_config)
      config = build_config(raw_config, owner)

      expect(config.content).to eq(
        "linters" => {
          "DeprecatedClasses" => {
            "enabled" => true,
          },
          "FinalNewline" => {
            "enabled" => true,
          },
        },
      )
    end
  end

  describe "#serialize" do
    it "serializes the parsed content into YAML" do
      raw_config = <<~YAML
        linters:
          DeprecatedClasses:
            enabled: true
      YAML
      config = build_config(raw_config)

      expect(config.serialize).to eq <<~YAML
        ---
        linters:
          DeprecatedClasses:
            enabled: true
      YAML
    end
  end
end
