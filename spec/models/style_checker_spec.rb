require 'rubocop'
require 'fast_spec_helper'
require "app/models/style_guide/ruby"
require "app/models/style_guide/coffee_script"
require "app/models/style_guide/null"
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
    config = "Style/EndOfLine:\n  Enabled: false"
    pull_request = double(
      :pull_request,
      pull_request_files: [stylish_file, violated_file],
      config_for: config
    )

    style_checker = StyleChecker.new(pull_request)

    expect(style_checker.violations).to eq [expected]
  end

  it "uses the Ruby style guide when given a Ruby file" do
    file = stub_modified_file("ruby.rb", %{puts "Hello World"})
    style_guide = double(:style_guide, violations: [])
    StyleGuide::Ruby.stub(new: style_guide)
    pull_request = double(:pull_request, pull_request_files: [file])

    StyleChecker.new(pull_request).violations

    expect(StyleGuide::Ruby).to have_received(:new)
  end

  it "uses the CoffeeScript style guide when given a CoffeeScript file" do
    file = stub_modified_file("coffee.coffee", %{alert "Hello World"})
    style_guide = double(:style_guide, violations: [])
    StyleGuide::CoffeeScript.stub(new: style_guide)
    pull_request = double(
      :pull_request,
      pull_request_files: [file]
    )

    StyleChecker.new(pull_request).violations

    expect(StyleGuide::CoffeeScript).to have_received(:new)
  end

  it "uses the Null style guide when given a file we do not support" do
    file = stub_modified_file("fortran.f", %{PRINT *, "Hello World!"\nEND})
    style_guide = double(:style_guide, violations: [])
    StyleGuide::Null.stub(new: style_guide)
    pull_request = double(
      :pull_request,
      pull_request_files: [file]
    )

    StyleChecker.new(pull_request).violations

    expect(StyleGuide::Null).to have_received(:new)
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
