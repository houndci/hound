require "spec_helper"
require "app/models/style_guide/base"

module StyleGuide
  class Test < Base; end
end

describe StyleGuide::Test do
  describe "#file_included?" do
    it "returns true" do
      style_guide = StyleGuide::Test.new(
        repo_config: double,
        build: double,
        repository_owner_name: "foo",
      )

      expect(style_guide.file_included?(double)).to eq true
    end
  end
end
