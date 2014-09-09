require "attr_extras"
require "rubocop"
require "fast_spec_helper"
require "active_support/core_ext"
require "app/models/style_guide/ruby"
require "app/models/style_guide/coffee_script"
require "app/models/style_guide/unsupported"
require 'app/models/style_checker'
require "app/models/violation"

describe StyleChecker, '#violations' do
  it "returns a collection of computed violations" do
    stylish_file = stub_modified_file("good.rb", "def good; end")
    violated_file = stub_modified_file("bad.rb", "def bad( a ); a; end  ")
    expected = Violation.new(
      violated_file.filename,
      violated_file.modified_line_at,
      ['Space inside parentheses detected.', 'Trailing whitespace detected.']
    )
    pull_request = double(
      :pull_request,
      pull_request_files: [stylish_file, violated_file],
      file_content: ""
    )

    style_checker = StyleChecker.new(pull_request)

    expect(style_checker.violations).to eq [expected]
  end

  context "when given a Ruby file" do
    it "uses the Ruby style guide" do
      file = stub_modified_file("ruby.rb", %{puts "Hello World"})
      style_guide = double(:style_guide, violations: [])
      pull_request = double(:pull_request, pull_request_files: [file])
      allow(pull_request).to receive(:file_content).and_return("")
      allow(StyleGuide::Ruby).to receive(:new).and_return(style_guide)

      StyleChecker.new(pull_request).violations

      expect(StyleGuide::Ruby).to have_received(:new)
    end
  end

  context "when given a CoffeeScript file" do
    context "and is enabled out" do
      it "uses CoffeeScript style guide" do
        config = <<-YAML.strip_heredoc
          CoffeeScript:
            Enabled: true
        YAML
        file = stub_modified_file("coffee.coffee", %{alert "Hello World"})
        style_guide = double(:style_guide, violations: [])
        pull_request = double(
          :pull_request,
          full_repo_name: "thoughtbot/upcase",
          pull_request_files: [file],
        )
        allow(pull_request).to receive(:file_content).
          with(StyleChecker::CONFIG_FILE).
          and_return(config)
        allow(StyleGuide::CoffeeScript).to receive(:new).and_return(style_guide)

        StyleChecker.new(pull_request).violations

        expect(StyleGuide::CoffeeScript).to have_received(:new)
      end
    end

    context "and CoffeeScript support is not enabled" do
      it "does not use CoffeeScript style guide" do
        file = stub_modified_file("coffee.coffee", %{alert "Hello World"})
        pull_request = double(:pull_request, pull_request_files: [file])
        allow(StyleGuide::CoffeeScript).to receive(:new)
        allow(pull_request).to receive(:file_content).and_return("")

        StyleChecker.new(pull_request).violations

        expect(StyleGuide::CoffeeScript).not_to have_received(:new)
      end
    end
  end

  context "with unsupported file type" do
    it "uses unsupported style guide" do
      file = stub_modified_file("fortran.f", %{PRINT *, "Hello World!"\nEND})
      pull_request = double(:pull_request, pull_request_files: [file])
      style_guide = double(:style_guide, violations: [])
      allow(StyleGuide::Unsupported).to receive(:new).and_return(style_guide)

      StyleChecker.new(pull_request).violations

      expect(StyleGuide::Unsupported).to have_received(:new)
    end
  end

  private

  def stub_modified_file(filename, contents)
    formatted_contents = "#{contents}\n"
    double(
      filename.split(".").first,
      filename: filename,
      content: formatted_contents,
      removed?: false,
      modified_line_at: 1
    )
  end
end
