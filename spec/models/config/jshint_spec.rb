require "spec_helper"
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

  describe "#excluded_files" do
    context "when no ignore file is configured" do
      it "returns the default paths" do
        commit = stubbed_commit(".jshintignore" => nil)
        config = build_config(commit)

        expect(config.excluded_files).to eq ["vendor/*"]
      end
    end

    context "when an ignore file is configured" do
      it "returns the paths specified in the file" do
        commit = stubbed_commit(
          ".jshintignore" => <<-EOS.strip_heredoc
              app/javascript/vendor/*
          EOS
        )
        config = build_config(commit)

        expect(config.excluded_files).to eq ["app/javascript/vendor/*"]
      end
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

  describe "#linter_names" do
    it "returns the names that the linter is accessible under" do
      commit = stubbed_commit({})
      config = build_config(commit)

      expect(config.linter_names).to match_array %w(javascript java_script jshint)
    end
  end

  def build_config(commit)
    Config::Jshint.new(stubbed_hound_config(commit), "jshint")
  end

  def stubbed_hound_config(commit)
    double(
      "HoundConfig",
      commit: commit,
      content: {
        "javascript" => {
          "enabled" => true,
          "config_file" => "config/jshint.json",
        },
      },
    )
  end
end
