# frozen_string_literal: true

require "app/models/config/base"
require "app/models/config/sass_lint"
require "app/models/config/parser"
require "app/models/config/parser_error"
require "app/models/config/serializer"
require "app/models/config_content"
require "app/models/missing_owner"

describe Config::SassLint do
  describe "#content" do
    context "when an owner is provided" do
      it "merges the configuration into the owner's configuration" do
        raw_config = <<~EOS
          rules:
            indentation:
              - 2
              -
                size: 2
        EOS
        owner_config = {
          "rules" => {
            "brace-style" => [
              2,
              { "style" => "stroustrup" },
            ],
          },
        }
        owner = instance_double("Owner", config_content: owner_config)
        config = build_config(raw_config, owner)

        expect(config.content).to eq(
          "rules" => {
            "indentation" => [2, { "size" => 2 }],
            "brace-style" => [2, { "style" => "stroustrup" }],
          },
        )
      end
    end

    context "when there is no owner" do
      it "parses the configuration using to return a hash" do
        raw_config = <<~EOS
          rules:
            indentation:
              - 2
              -
                size: 2
        EOS
        config = build_config(raw_config)

        expect(config.content).to eq(
          "rules" => {
            "indentation" => [2, { "size" => 2 }],
          },
        )
      end
    end
  end

  describe "#serialize" do
    it "serializes the parsed content into YAML" do
      raw_config = <<~EOS
        rules:
          indentation:
            - 2
            -
              size: 2
              foo: bar
      EOS
      config = build_config(raw_config)

      expect(config.serialize).to eq <<~EOS
        ---
        rules:
          indentation:
          - 2
          - size: 2
            foo: bar
        EOS
    end
  end
end
