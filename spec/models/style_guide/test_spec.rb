require "spec_helper"
require "app/models/style_guide/base"

module StyleGuide
  class Test < Base; end
end

describe StyleGuide::Test do
  describe "#file_included?" do
    context "when #file_included? is not defined" do
      it "raises with a helpful message" do
        style_guide = StyleGuide::Test.new(
          repo_config: double,
          build: double,
          repository_owner_name: "foo",
        )

        expect { style_guide.file_included?(double) }.to raise_error(
          "Implement #file_included? in your StyleGuide class"
        )
      end
    end
  end
end
