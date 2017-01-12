require "app/models/config/base"
require "app/models/config/eslint"
require "app/models/config/parser"
require "app/models/config/parser_error"
require "app/models/config/serializer"
require "app/models/config/json_with_comments"
require "app/models/config_content"
require "app/models/missing_owner"

describe Config::Eslint do
  describe "#content" do
    context "when an owner is provided" do
      it "merges the configuration into the owner's configuration" do
        raw_config = <<~EOS
          {
            "rules": {
              "brace-style": [
                2,
                "1tbs",
                { "allowSingleLine": true }
              ]
            }
          }
        EOS
        owner_config = {
          "rules" => {
            "no-empty" => [
              2,
              { "allowEmptyCatch" => true },
            ],
          },
        }
        owner = instance_double("Owner", config_content: owner_config)
        config = build_config(raw_config, owner)

        expect(config.content).to eq(
          "rules" => {
            "brace-style" => [
              2,
              "1tbs",
              { "allowSingleLine" => true },
            ],
            "no-empty" => [
              2,
              { "allowEmptyCatch" => true },
            ],
          },
        )
      end
    end

    context "when the owner is missing" do
      it "parses the configuration using YAML" do
        raw_config = <<~EOS
          rules:
            quotes: [2, "double"]
        EOS
        config = build_config(raw_config)

        expect(config.content).to eq("rules" => { "quotes" => [2, "double"] })
      end
    end

    context "when configuration is linter-flavored JSON format" do
      it "parses the configuration" do
        raw_config = <<~EOS
          {
            "foo": 1, // eslint JSON flavor can have comments
            "bar": 2,
          }
        EOS
        config = build_config(raw_config)

        expect(config.content).to eq("foo" => 1, "bar" => 2)
      end
    end
  end

  describe "#serialize" do
    it "serializes the content into JSON" do
      raw_config = <<~EOS
        rules:
          quotes: [2, "double"]
      EOS
      config = build_config(raw_config)

      expect(config.serialize).to eq(
        "{\"rules\":{\"quotes\":[2,\"double\"]}}",
      )
    end
  end
end
