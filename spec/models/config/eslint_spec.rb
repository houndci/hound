require "spec_helper"
require "app/models/config/base"
require "app/models/config/eslint"
require "app/models/config/parser"
require "app/models/config/serializer"
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
