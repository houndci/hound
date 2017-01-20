require "spec_helper"
require "app/models/config/base"
require "app/models/config/coffee_script"
require "app/models/config/parser"
require "app/models/config/parser_error"
require "app/models/config_content"
require "app/models/config/json_with_comments"
require "app/models/missing_owner"

describe Config::CoffeeScript do
  describe "#content" do
    context "with a modern coffeescript config" do
      it "returns the content from GitHub as a hash" do
        raw_config = <<~EOS
          { "arrow_spacing": { "level": "error" } }
        EOS
        config = build_config(raw_config)

        result = config.content

        expect(result).to eq(
          "arrow_spacing" => { "level" => "error" },
        )
      end
    end

    context "with a legacy coffeescript config" do
      it "returns the content from GitHub as a hash" do
        raw_config = <<~EOS
          { "arrow_spacing": { "level": "error" } }
        EOS
        config = build_config(raw_config)

        result = config.content

        expect(result).to eq(
          "arrow_spacing" => { "level" => "error" },
        )
      end
    end

    context "config with comments and trailing commas" do
      it "returns the content from Github as a hash" do
        raw_config = <<~EOS
          {
            "arrow_spacing": {
                // this should be stripped out
                "level": "error",
            }
          }
        EOS
        config = build_config(raw_config)

        result = config.content

        expect(result).to eq(
          "arrow_spacing" => { "level" => "error" },
        )
      end
    end

    context "when the config file is invalid" do
      it "raises an exception" do
        raw_config = <<~EOS
          { invalid_json: [ }
        EOS
        config = build_config(raw_config)

        expect { config.content }.to raise_error(Config::ParserError)
      end
    end
  end
end
