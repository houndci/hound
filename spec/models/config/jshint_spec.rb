require "spec_helper"
require "lib/js_ignore"
require "app/models/config/base"
require "app/models/config/jshint"
require "app/models/config/parser"
require "app/models/config/serializer"

describe Config::Jshint do
  describe "#content" do
    it "parses the configuration using JSON" do
      raw_config = <<~EOS
        {
          "maxlen": 80
        }
      EOS
      config = Config::Jshint.new(raw_config)

      expect(config.content).to eq("maxlen" => 80)
    end
  end

  describe "#serialize" do
    it "serializes the parsed content into JSON" do
      raw_config = <<~EOS
        {
          "maxlen": 80
        }
      EOS
      config = Config::Jshint.new(raw_config)

      expect(config.serialize).to eq "{\"maxlen\":80}"
    end
  end

  describe "#merge" do
    it "overrides the config values with the supplied config" do
      raw_config = <<~EOS
        {
          "maxlen": 80,
          "some_other_value": "foo"
        }
      EOS
      raw_overrides = <<~EOS
        {
          "maxlen": 60
        }
      EOS
      config = Config::Jshint.new(raw_config)
      merged_config = config.merge(raw_overrides)

      expect(merged_config.serialize).to eq(
        "{\"maxlen\":60,\"some_other_value\":\"foo\"}",
      )
    end
  end
end
