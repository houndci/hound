require "spec_helper"
require "app/models/config/base"
require "app/models/config/eslint"
require "app/models/config/parser"
require "app/models/config/parser_error"
require "app/models/config/serializer"
require "app/models/config/json_with_comments"
require "yaml"

describe Config::Eslint do
  describe "#content" do
    it "parses the configuration using YAML" do
      raw_config = <<-EOS.strip_heredoc
        rules:
          quotes: [2, "double"]
      EOS
      commit = stubbed_commit("config/.eslintrc" => raw_config)
      config = build_config(commit)

      expect(config.content).to eq("rules" => { "quotes" => [2, "double"] })
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

  def build_config(commit)
    hound_config = double(
      "HoundConfig",
      commit: commit,
      content: {
        "eslint" => { "enabled": true, "config_file" => "config/.eslintrc" },
      },
    )

    Config::Eslint.new(hound_config, "eslint")
  end
end
