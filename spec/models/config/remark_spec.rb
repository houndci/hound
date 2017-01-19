require "app/models/config/base"
require "app/models/config/remark"
require "app/models/config/parser"
require "app/models/config/serializer"
require "app/models/config_content"
require "app/models/missing_owner"

describe Config::Remark do
  describe "#content" do
    it "parses the configuration using JSON" do
      raw_config = <<~EOS
        {
          "heading-style": "setext"
        }
      EOS
      config = build_config(raw_config)

      expect(config.content).to eq Config::Parser.json(raw_config)
    end
  end

  describe "#serialize" do
    it "serializes the content into JSON" do
      raw_config = <<~EOS
        {
          "heading-style": "setext"
        }
      EOS
      config = build_config(raw_config)

      expect(config.serialize).to eq "{\"heading-style\":\"setext\"}"
    end
  end
end
