require "spec_helper"
require "app/models/config/base"
require "app/models/config/flake8"
require "app/models/config/parser"
require "app/models/config/parser_error"
require "app/models/config/serializer"
require "inifile"

describe Config::Flake8 do
  describe "#content" do
    it "returns the parsed configuration" do
      raw_config = <<-EOS.strip_heredoc
        [flake8]
        max-line-length = 160
      EOS
      commit = stubbed_commit("config/python.ini" => raw_config)
      config = build_config(commit)

      expect(config.content).to eq("flake8" => { "max-line-length" => 160 })
    end

    context "when there is no config content for the given linter" do
      it "returns the empty string" do
        hound_config = double(
          "HoundConfig",
          commit: double("Commit"),
          content: {},
        )
        config = Config::Flake8.new(hound_config)

        expect(config.content).to eq ""
      end
    end
  end

  describe "#serialize" do
    it "returns the parsed content back to INI" do
      raw_config = <<-EOS.strip_heredoc
        [flake8]
        max-line-length = 160
      EOS
      commit = stubbed_commit("config/python.ini" => raw_config)
      config = build_config(commit)

      expect(config.serialize).to eq raw_config
    end
  end

  describe "#linter_names" do
    it "returns the names that the linter is accessible under" do
      commit = stubbed_commit({})
      config = build_config(commit)

      expect(config.linter_names).to match_array %w(python flake8)
    end
  end

  def build_config(commit)
    hound_config = double(
      "HoundConfig",
      commit: commit,
      content: {
        "flake8" => { "enabled": true, "config_file" => "config/python.ini" },
      },
    )

    Config::Flake8.new(hound_config)
  end
end
