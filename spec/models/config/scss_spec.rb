require "spec_helper"
require "app/models/config/base"
require "app/models/config/scss"
require "app/models/config/parser"
require "app/models/config/serializer"

describe Config::Scss do
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

  def build_config(commit)
    hound_config = double(
      "HoundConfig",
      commit: commit,
      content: {
        "scss" => { "config_file" => "config/scss.yml" },
      },
    )

    Config::Scss.new(hound_config, "scss")
  end
end
