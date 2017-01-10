require "spec_helper"
require "app/models/config/base"
require "app/models/config/parser"
require "app/models/config/parser_error"
require "app/models/config/python"
require "app/models/config/serializer"
require "app/models/config_content"
require "app/models/missing_owner"
require "app/services/build_config"
require "inifile"

describe Config::Python do
  describe "#content" do
    context "when an owner is provided" do
      it "merges the parsed config with the owner's" do
        raw_config = <<~EOS
          [flake8]
          max-line-length = 160
        EOS
        commit = stubbed_commit("config/python.ini" => raw_config)
        hound_config = instance_double("HoundConfig")
        owner = instance_double("Owner", hound_config: hound_config)
        config = build_config(commit, owner: owner)
        owner_config = instance_double(
          "Config::Python",
          content: {
            "flake8" => {
              "max-complexity" => 10,
            },
          },
        )
        allow(BuildConfig).to receive(:for).and_return(owner_config)

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
        owner_config = instance_double("Config::Python", content: {})
        allow(BuildConfig).to receive(:for).and_return(owner_config)

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
        owner_config = instance_double("Config::Python", content: {})
        allow(BuildConfig).to receive(:for).and_return(owner_config)

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
      owner_config = instance_double("Config::Python", content: {})
      allow(BuildConfig).to receive(:for).and_return(owner_config)

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
