require "spec_helper"
require "app/models/config/base"
require "app/models/config/coffeelint"
require "app/models/config/parser"
require "app/models/config/parser_error"
require "app/models/config_content"
require "app/models/config/json_with_comments"
require "app/models/missing_owner"

RSpec.describe Config::Coffeelint do
  describe "#content" do
    it "returns the content from GitHub as a hash" do
      raw_config = <<~JSON
        { "arrow_spacing": { "level": "error" } }
      JSON
      config = build_config(raw_config)

      result = config.content

      expect(result).to eq(
        "arrow_spacing" => { "level" => "error" },
      )
    end

    context "when config has comments and trailing commas" do
      it "returns the content from GitHub as a hash" do
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
