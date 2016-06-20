require "spec_helper"
require "app/models/config/base"
require "app/models/config/scss_lint"
require "app/models/config/parser"
require "app/models/config/serializer"

describe Config::ScssLint do
  describe "#content" do
    it "parses the configuration using YAML" do
      raw_config = <<-EOS.strip_heredoc
        linters:
          BangFormat:
            enabled: true
            space_before_bang: true
            space_after_bang: false
      EOS
      commit = stubbed_commit("config/scss.yml" => raw_config)
      config = build_config(commit)

      expect(config.content).to eq Config::Parser.yaml(raw_config)
    end
  end

  describe "#serialize" do
    it "serializes the parsed content into YAML" do
      raw_config = <<-EOS.strip_heredoc
        linters:
          BangFormat:
            enabled: true
            space_before_bang: true
            space_after_bang: false
      EOS
      commit = stubbed_commit("config/scss.yml" => raw_config)
      config = build_config(commit)

      expect(config.serialize).to eq <<-EOS.strip_heredoc
        ---
        linters:
          BangFormat:
            enabled: true
            space_before_bang: true
            space_after_bang: false
      EOS
    end
  end

  describe "#linter_names" do
    it "returns the names that the linter is accessible under" do
      commit = stubbed_commit({})
      config = build_config(commit)

      expect(config.linter_names).
        to match_array %w(scss scsslint scss-lint)
    end
  end

  def build_config(commit)
    hound_config = double(
      "HoundConfig",
      commit: commit,
      content: {
        "scss" => { "config_file" => "config/scss.yml" },
      },
    )

    Config::ScssLint.new(hound_config)
  end
end
