require "spec_helper"
require "app/models/config/base"
require "app/models/config/scss"
require "app/models/config/parser"
require "app/models/config/serializer"
require "app/models/config_content"
require "app/models/missing_owner"

describe Config::Scss do
  describe "#content" do
    context "when an owner is provided" do
      it "merges the configuration into the owner's configuration" do
        raw_config = <<~EOS
          linters:
            BangFormat:
              enabled: true
              space_before_bang: true
              space_after_bang: false
        EOS
        owner_config = {
          "linters" => {
            "BemDepth" => {
              "enabled" => false,
              "max_elements" => 1,
            },
          },
        }
        owner = instance_double("Owner", config_content: owner_config)
        config = build_config(raw_config, owner)

        expect(config.content).to eq(
          "linters" => {
            "BangFormat" => {
              "enabled" => true,
              "space_after_bang" => false,
              "space_before_bang" => true,
            },
            "BemDepth" => {
              "enabled" => false,
              "max_elements" => 1,
            },
          },
        )
      end
    end

    context "when there is no owner" do
      it "parses the configuration using YAML" do
        raw_config = <<~EOS
          linters:
            BangFormat:
              enabled: true
              space_before_bang: true
              space_after_bang: false
        EOS
        config = build_config(raw_config)

        expect(config.content).to eq(
          "linters" => {
            "BangFormat" => {
              "enabled" => true,
              "space_after_bang" => false,
              "space_before_bang" => true,
            },
          },
        )
      end
    end
  end

  describe "#serialize" do
    it "serializes the parsed content into YAML" do
      raw_config = <<~EOS
        linters:
          BangFormat:
            enabled: true
            space_before_bang: true
            space_after_bang: false
      EOS
      config = build_config(raw_config)

      expect(config.serialize).to eq <<~EOS
        ---
        linters:
          BangFormat:
            enabled: true
            space_before_bang: true
            space_after_bang: false
      EOS
    end
  end
end
