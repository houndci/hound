require "app/models/missing_owner"
require "app/models/config_content"
require "app/models/config/base"
require "app/models/config/phpcs"

RSpec.describe Config::Phpcs do
  describe "#content" do
    it "returns the raw string" do
      config = build_config(raw_config)

      expect(config.content).to eq raw_config
    end
  end

  describe "#serialize" do
    it "returns the raw content string" do
      config = build_config(raw_config)

      expect(config.serialize).to eq raw_config
    end
  end

  def raw_config
    <<~XML
      <?xml version="1.0"?>
      <ruleset name="Custom Standard" namespace="CustomStandard">
        <rule ref="PEAR">
          <exclude name="PEAR.Commenting.FileComment.Missing"/>
        </rule>
      </ruleset>
    XML
  end
end
