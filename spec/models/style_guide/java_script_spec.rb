require "fast_spec_helper"
require "jshintrb"
require "active_support/inflector"
require "app/models/violation"
require "app/models/style_guide/base"
require "app/models/style_guide/java_script"

describe StyleGuide::JavaScript do
  describe "#violations_in_file" do
    context "with default config" do
      context "when semicolon is missing" do
        it "returns violation" do
          style_guide = StyleGuide::JavaScript.new(
            double("RepoConfig", for: {})
          )
          file = double(:file, content: "var blahh = 'blahh'").as_null_object

          violations = style_guide.violations_in_file(file)

          expect(violations.first.messages).to include "Missing semicolon."
        end
      end
    end

    context "when semicolon check is disabled in config" do
      context "when semicolon is missing" do
        it "returns no violation" do
          style_guide = StyleGuide::JavaScript.new(
            double("RepoConfig", for: { "asi" => true })
          )
          file = double(:file, content: "var blahh = 'blahh'").as_null_object

          violations = style_guide.violations_in_file(file)

          expect(violations.first.messages).not_to include "Missing semicolon."
        end
      end
    end

    context "when jshintrb returns nil violation" do
      it "returns empty array" do
        style_guide = StyleGuide::JavaScript.new(double("RepoConfig", for: {}))
        file = double(:file).as_null_object
        Jshintrb.stub(lint: [nil])

        violations = style_guide.violations_in_file(file)

        expect(violations).to be_empty
      end
    end
  end
end
