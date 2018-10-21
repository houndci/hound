require "app/models/config/base"
require "app/models/config/haml_lint"
require "app/models/config/parser"
require "app/models/config/parser_error"
require "app/models/config/serializer"
require "app/models/config_content"
require "app/models/missing_owner"

describe Config::HamlLint do
  describe "#content" do
    context "when an owner is provided" do
      it "merges the configuration into the owner's configuration" do
        raw_config = <<~EOS
          linters:
            AltText:
              enabled: true
        EOS
        owner_config = {
          "linters" => {
            "ClassAttributeWithStaticValue" => { "enabled" => true },
          },
        }
        owner = instance_double("Owner", config_content: owner_config)
        config = build_config(raw_config, owner)

        expect(config.content).to eq(
          "linters" => {
            "AltText" => { "enabled" => true },
            "ClassAttributeWithStaticValue" => { "enabled" => true },
          },
        )
      end
    end

    context "when the given content is valid" do
      it "returns the content from GitHub as a hash" do
        raw_config = <<~EOS
          linters:
            AltText:
              enabled: true
        EOS
        config = build_config(raw_config)

        expect(config.content).to eq(
          "linters" => { "AltText" => { "enabled" => true } },
        )
      end
    end

    context "when the given content is invalid" do
      context "when the result is not a hash" do
        it "raises a type exception" do
          raw_config = <<~EOS
            !
          EOS
          config = build_config(raw_config)

          expect { config.content }.to raise_error(
            Config::ParserError,
            "config/linter-config.any format is invalid",
          )
        end
      end

      context "when the content is invalid yaml" do
        it "raises an exception" do
          raw_config = <<~EOS
            ruby: !ruby/object
              ;foo:
          EOS
          config = build_config(raw_config)

          expect { config.content }.to raise_error(Config::ParserError)
        end
      end
    end
  end
end
