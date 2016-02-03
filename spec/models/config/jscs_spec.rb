require "spec_helper"
require "app/models/config/base"
require "app/models/config/jscs"
require "app/models/config/parser"
require "app/models/config/serializer"

describe Config::Jscs do
  describe "#content" do
    it "parses the configuration using YAML" do
      raw_config = <<-EOS.strip_heredoc
        { "disallowKeywordsInComments": true }
      EOS
      commit = stubbed_commit("config/.jscsrc" => raw_config)
      config = build_config(commit)

      expect(config.content).to eq("disallowKeywordsInComments" => true)
    end
  end

  describe "#serialize" do
    it "serializes the parsed content into YAML" do
      raw_config = <<-EOS.strip_heredoc
        { "disallowKeywordsInComments": true }
      EOS
      commit = stubbed_commit("config/.jscsrc" => raw_config)
      config = build_config(commit)

      expect(config.serialize).to eq "{\"disallowKeywordsInComments\":true}"
    end
  end

  def build_config(commit)
    hound_config = double(
      "HoundConfig",
      commit: commit,
      content: {
        "jscs" => { "enabled": true, "config_file" => "config/.jscsrc" },
      },
    )

    Config::Jscs.new(hound_config, "jscs")
  end
end
