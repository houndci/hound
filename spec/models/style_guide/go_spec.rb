require "fast_spec_helper"
require "golint"
require "active_support/inflector"
require "app/models/violation"
require "app/models/style_guide/base"
require "app/models/style_guide/go"

describe StyleGuide::Go do
  describe "#violations_in_file" do
    context "with default config" do
      context "when semicolon is missing" do
        it "returns violation" do
          style_guide = StyleGuide::Go.new(
            double("RepoConfig", for: {})
          )
          file = double(:file, content: 'item_id := vars["item_id"]', filename: 'sample.go', line_at: nil)

          violations = style_guide.violations_in_file(file)

          expect(violations.first.messages).to include "expected 'package', found 'IDENT' item_id"
        end
      end
    end
  end
end
