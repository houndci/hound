require "spec_helper"
require "lib/js_ignore"
require "app/models/config/base"
require "app/models/config/jshint"
require "app/models/config/parser"
require "app/models/config/serializer"

describe Config::Jshint do
  describe "#content" do
    it "parses the configuration using JSON" do
      raw_config = <<-EOS.strip_heredoc
        {
          "maxlen": 80
        }
      EOS
      commit = stubbed_commit("config/jshint.json" => raw_config)
      config = build_config(commit)

      expect(config.content).to eq("maxlen" => 80)
    end
  end

  describe "#serialize" do
    it "serializes the parsed content into JSON" do
      raw_config = <<-EOS.strip_heredoc
        {
          "maxlen": 80
        }
      EOS
      commit = stubbed_commit("config/jshint.json" => raw_config)
      config = build_config(commit)

      expect(config.serialize).to eq "{\"maxlen\":80}"
    end
  end

  def build_config(commit)
    Config::Jshint.new(stubbed_hound_config(commit))
  end

  def stubbed_hound_config(commit)
    double(
      "HoundConfig",
      commit: commit,
      content: {
        "jshint" => {
          "enabled" => true,
          "config_file" => "config/jshint.json",
        },
      },
    )
  end
end
