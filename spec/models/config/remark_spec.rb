require "spec_helper"
require "app/models/config/base"
require "app/models/config/remark"
require "app/models/config/parser"
require "app/models/config/serializer"
require "app/models/config_content"
require "app/models/missing_owner"
require "app/services/build_config"

describe Config::Remark do
  describe "#content" do
    it "parses the configuration using JSON" do
      raw_config = <<-EOS.strip_heredoc
        {
          "heading-style": "setext"
        }
      EOS
      commit = stubbed_commit("config/.remarkrc" => raw_config)
      config = build_config(commit)
      owner_config = instance_double("Config::Remark", content: {})
      allow(BuildConfig).to receive(:for).and_return(owner_config)

      expect(config.content).to eq Config::Parser.json(raw_config)
    end
  end

  describe "#serialize" do
    it "serializes the content into JSON" do
      raw_config = <<-EOS.strip_heredoc
        {
          "heading-style": "setext"
        }
      EOS
      commit = stubbed_commit("config/.remarkrc" => raw_config)
      config = build_config(commit)
      owner_config = instance_double("Config::Remark", content: {})
      allow(BuildConfig).to receive(:for).and_return(owner_config)

      expect(config.serialize).to eq "{\"heading-style\":\"setext\"}"
    end
  end

  def build_config(commit)
    hound_config = double(
      "HoundConfig",
      commit: commit,
      content: {
        "remark" => { "enabled": true, "config_file" => "config/.remarkrc" },
      },
    )

    Config::Remark.new(hound_config)
  end
end
