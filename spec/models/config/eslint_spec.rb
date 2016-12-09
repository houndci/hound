require "spec_helper"
require "app/models/config/base"
require "app/models/config/eslint"
require "app/models/config/parser"
require "app/models/config/parser_error"
require "app/models/config/serializer"
require "app/models/config/json_with_comments"
require "yaml"

describe Config::Eslint do
  describe "#serialize" do
    it "serializes the content" do
      raw_config = <<-EOS.strip_heredoc
        rules:
          quotes: [2, "double"]
      EOS
      commit = stubbed_commit("config/.eslintrc.yaml" => raw_config)
      config = build_config(commit)

      expect(config.serialize).to eq(
        {
          raw_content: "rules:\n  quotes: [2, \"double\"]\n",
          file_name: "config/.eslintrc.yaml",
          hound_config_eslint_version: 2
        }.to_json
      )
    end
  end

  def build_config(commit)
    hound_config = double(
      "HoundConfig",
      commit: commit,
      content: {
        "eslint" => {
          "enabled": true,
          "config_file" => "config/.eslintrc.yaml"
        },
      },
    )

    Config::Eslint.new(hound_config)
  end
end
