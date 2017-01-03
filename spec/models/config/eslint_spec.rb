require "spec_helper"
require "app/models/config/base"
require "app/models/config/eslint"
require "app/models/config/parser"
require "app/models/config/parser_error"
require "app/models/config/serializer"
require "app/models/config/json_with_comments"
require "app/models/missing_owner"
require "app/services/build_owner_hound_config"
require "yaml"

describe Config::Eslint do
  describe "#content" do
    context "when an owner is provided" do
      it "merges the configuration into the owner's configuration" do
        owner = instance_double(
          "Owner",
          hound_config: {
            "rules" => {
              "no-empty" => [
                2,
                { "allowEmptyCatch" => true },
              ],
            },
          },
        )
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
        commit = stubbed_commit("config/.eslintrc" => raw_config)
        config = build_config(commit, owner)

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
        commit = stubbed_commit("config/.eslintrc" => raw_config)
        config = build_config(commit)

        expect(config.content).to eq("rules" => { "quotes" => [2, "double"] })
      end
    end

    context "when configuration is linter-flavored JSON format" do
      it "parses the configuration" do
        raw_config = <<-EOS.strip_heredoc
          {
            "foo": 1, // eslint JSON flavor can have comments
            "bar": 2,
          }
        EOS
        commit = stubbed_commit("config/.eslintrc" => raw_config)
        config = build_config(commit)

        expect(config.content).to eq("foo" => 1, "bar" => 2)
      end
    end
  end

  describe "#serialize" do
    it "serializes the content into JSON" do
      raw_config = <<-EOS.strip_heredoc
        rules:
          quotes: [2, "double"]
      EOS
      commit = stubbed_commit("config/.eslintrc" => raw_config)
      config = build_config(commit)

      expect(config.serialize).to eq(
        "{\"rules\":{\"quotes\":[2,\"double\"]}}",
      )
    end
  end

  def build_config(commit, owner = MissingOwner.new)
    hound_config = double(
      "HoundConfig",
      commit: commit,
      content: {
        "eslint" => { "enabled": true, "config_file" => "config/.eslintrc" },
      },
    )

    Config::Eslint.new(hound_config, owner: owner)
  end
end
