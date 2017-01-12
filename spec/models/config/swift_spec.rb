require "spec_helper"
require "app/models/config/base"
require "app/models/config/swift"
require "app/models/config/parser"
require "app/models/config/serializer"
require "app/models/config_content"
require "app/models/missing_owner"

describe Config::Swift do
  describe "#content" do
    context "when an owner is provided" do
      it "merges the configuration into the owner's configuration" do
        raw_config = <<~EOS
          disabled_rules:
            - colon
        EOS
        owner_config = { "excluded" => ["Carthage", "Pods"] }
        owner = instance_double("Owner", config_content: owner_config)
        config = build_config(raw_config, owner)

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
        config = build_config(raw_config)

        expect(config.content).to eq("disabled_rules" => ["colon"])
      end
    end
  end

  describe "#serialize" do
    it "serializes the parsed content into YAML" do
      raw_config = <<~EOS
        disabled_rules:
          - colon
      EOS
      config = build_config(raw_config)

      expect(config.serialize).to eq "---\ndisabled_rules:\n- colon\n"
    end
  end
end
