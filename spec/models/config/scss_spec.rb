require "spec_helper"
require "app/models/config/base"
require "app/models/config/scss"
require "app/models/config/parser"
require "app/models/config/serializer"

describe Config::Scss do
  describe "#serialize" do
    it "returns the configuration it was initialized with" do
      raw_config = <<~EOS
        linters:
          BangFormat:
            enabled: true
            space_before_bang: true
            space_after_bang: false
      EOS
      config = Config::Scss.new(raw_config)

      result = config.serialize

      expect(result).to eq("---\n#{raw_config}")
    end

    it "combines the existing configuration with the overrides" do
      raw_config = <<~EOS
        linters:
          BangFormat:
            enabled: true
            space_before_bang: true
            space_after_bang: false
      EOS
      raw_overrides = <<~EOS
        linters:
          BangFormat:
            enabled: false
      EOS
      config = Config::Scss.new(raw_config)

      result = config.serialize(raw_overrides)

      expect(result).to eq <<~EOS
        ---
        linters:
          BangFormat:
            enabled: false
            space_before_bang: true
            space_after_bang: false
      EOS
    end
  end
end
