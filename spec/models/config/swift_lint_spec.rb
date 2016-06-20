require "spec_helper"
require "app/models/config/base"
require "app/models/config/swift_lint"
require "app/models/config/parser"
require "app/models/config/serializer"

describe Config::SwiftLint do
  describe "#content" do
    it "parses the configuration using YAML" do
      raw_config = <<-EOS.strip_heredoc
        disabled_rules:
          - colon
      EOS
      commit = stubbed_commit("config/swiftlint.yml" => raw_config)
      config = build_config(commit)

      expect(config.content).to eq Config::Parser.yaml(raw_config)
    end
  end

  describe "#serialize" do
    it "serializes the parsed content into YAML" do
      raw_config = <<-EOS.strip_heredoc
        disabled_rules:
          - colon
      EOS
      commit = stubbed_commit("config/swiftlint.yml" => raw_config)
      config = build_config(commit)

      expect(config.serialize).to eq "---\ndisabled_rules:\n- colon\n"
    end
  end

  describe "#linter_names" do
    it "returns the names that the linter is accessible under" do
      commit = stubbed_commit({})
      config = build_config(commit)

      expect(config.linter_names).to match_array %w(swift swiftlint)
    end
  end

  def build_config(commit)
    hound_config = double(
      "HoundConfig",
      commit: commit,
      content: {
        "swiftlint" => {
          "enabled" => true,
          "config_file" => "config/swiftlint.yml",
        },
      },
    )

    Config::SwiftLint.new(hound_config)
  end
end
