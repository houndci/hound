require "spec_helper"
require "app/models/config/base"
require "app/models/config/swift"
require "app/models/config/parser"
require "app/models/config/serializer"
require "app/models/missing_owner"

describe Config::Swift do
  describe "#content" do
    context "when an owner is provided" do
      it "merges the configuration into the owner's configuration" do
        owner = instance_double(
          "Owner",
          hound_config: {
            "excluded" => ["Carthage", "Pods"],
          },
        )
        raw_config = <<~EOS
          disabled_rules:
            - colon
        EOS
        commit = stubbed_commit("config/swiftlint.yml" => raw_config)
        config = build_config(commit, owner)

        expect(config.content).to eq(
          "disabled_rules" => ["colon"],
          "excluded" => ["Carthage", "Pods"],
        )
      end
    end

    context "when there is no owner" do
      it "parses the configuration using YAML" do
        raw_config = <<~EOS
          disabled_rules:
            - colon
        EOS
        commit = stubbed_commit("config/swiftlint.yml" => raw_config)
        config = build_config(commit)

        expect(config.content).to eq("disabled_rules" => ["colon"])
      end
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

  def build_config(commit, owner = MissingOwner.new)
    hound_config = double(
      "HoundConfig",
      commit: commit,
      content: {
        "swift" => { "enabled": true, "config_file" => "config/swiftlint.yml" },
      },
    )

    Config::Swift.new(hound_config, owner: owner)
  end
end
