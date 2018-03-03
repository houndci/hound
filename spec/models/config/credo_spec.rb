# frozen_string_literal: true

require "app/models/config/base"
require "app/models/config/credo"
require "app/models/config/parser"
require "app/models/config/serializer"
require "app/models/missing_owner"

describe Config::Credo do
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
    <<~EOS
        %{
          configs: [
            %{
              name: "default",
              files: %{
                included: ["lib/", "src/", "web/", "apps/"],
                excluded: [],
              },
            }
          ]
        }
    EOS
  end
end
