require "phpcs"
require "fast_spec_helper"

require "app/models/style_guide/base"
require "app/models/style_guide/php"
require "app/models/violation"

describe StyleGuide::PHP do
  describe "#violations_in_file" do
    context "with default configuration" do
      context "for long line" do
        it "returns violation" do
          file = double(
            :file,
            content: "<?php " + "1" * 300,
            filename: "lib/test.php",
            line_at: [1],
          )
          repo_config = double("RepoConfig", enabled_for?: true, for: {})
          style_guide = StyleGuide::PHP.new(repo_config)

          violations = style_guide.violations_in_file(file)

          expect(violations.flat_map(&:messages)).to be_any do |m|
            m =~ /exceeds 120/i
          end
        end
      end
    end

    context "with violation on unchanged line" do
      it "finds no violations" do
        file = double(
          :file,
          content: "<?php\n1    ",
          filename: "lib/test.php",
          line_at: nil,
        )
        repo_config = double("RepoConfig", enabled_for?: true, for: "Zend")
        style_guide = StyleGuide::PHP.new(repo_config)

        violations = style_guide.violations_in_file(file)

        expect(violations.count).to eq 0
      end
    end

    context "with non default configuration" do
      it "finds a violations" do
        file = double(
          :file,
          content: "<?php    \n",
          filename: "lib/test.php",
          line_at: [1],
        )
        repo_config = double("RepoConfig", enabled_for?: true, for: "Squiz")
        style_guide = StyleGuide::PHP.new(repo_config)

        violations = style_guide.violations_in_file(file)

        expect(violations.flat_map(&:messages)).to be_any do |m|
          m =~ /whitespace found/i
        end
      end
    end
  end
end
