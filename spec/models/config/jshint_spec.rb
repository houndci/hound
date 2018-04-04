require "app/models/config/base"
require "app/models/config/jshint"
require "app/models/config/parser"
require "app/models/config/serializer"
require "app/models/config/parser_error"
require "app/models/config_content"
require "app/models/missing_owner"

describe Config::Jshint do
  describe "#content" do
    context "when configuration is valid JSON" do
      it "parses the configuration using JSON" do
        raw_config = <<~JSON
          {
            "maxlen": 80
          }
        JSON
        config = build_config(raw_config)

        expect(config.content).to eq("maxlen" => 80)
      end
    end

    context "when configuration is blank" do
      it "returns empty hash" do
        config = build_config("")

        expect(config.content).to eq({})
      end
    end

    context "when configuration is invalid JSON" do
      it "raises Config::ParserError" do
        raw_config = <<~JSON
          esversion: 6
        JSON

        config = build_config(raw_config)

        expect { config.content }.to(
          raise_error(Config::ParserError)
        )
      end
    end
  end

  describe "#serialize" do
    it "serializes the parsed content into JSON" do
      raw_config = <<~JSON
        {
          "maxlen": 80
        }
      JSON
      config = build_config(raw_config)

      expect(config.serialize).to eq "{\"maxlen\":80}"
    end
  end
end
