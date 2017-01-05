require "spec_helper"
require "app/models/config/base"
require "app/models/config/parser"
require "app/models/config/parser_error"
require "app/models/config/python"
require "app/models/config/serializer"
require "app/models/missing_owner"
require "inifile"

describe Config::Python do
  describe "#content" do
    context "when an owner is provided" do
      it "merges the parsed config with the owner's" do
        owner = instance_double(
          "Owner",
          hound_config: {
            "flake8" => {
              "max-complexity" => 10,
            },
          },
        )
        raw_config = <<~EOS
          [flake8]
          max-line-length = 160
        EOS
        commit = stubbed_commit("config/python.ini" => raw_config)
        config = build_config(commit, owner: owner)

        expect(config.content).to eq(
          "flake8" => {
            "max-complexity" => 10,
            "max-line-length" => 160,
          },
        )
      end
    end

    context "when there is no owner" do
      it "returns the parsed configuration" do
        raw_config = <<~EOS
          [flake8]
          max-line-length = 160
        EOS
        commit = stubbed_commit("config/python.ini" => raw_config)
        config = build_config(commit)

        expect(config.content).to eq("flake8" => { "max-line-length" => 160 })
      end
    end

    context "when there is no config content for the given linter" do
      it "is an empty hash" do
        hound_config = double(
          "HoundConfig",
          commit: double("Commit"),
          content: {},
        )
        config = Config::Python.new(hound_config)

        expect(config.content).to eq({})
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

  def build_config(commit, owner: MissingOwner.new)
    hound_config = double(
      "HoundConfig",
      commit: commit,
      content: {
        "python" => { "enabled": true, "config_file" => "config/python.ini" },
      },
    )

    Config::Python.new(hound_config, owner: owner)
  end
end
