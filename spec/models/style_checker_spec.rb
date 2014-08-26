require 'rubocop'
require 'fast_spec_helper'
require "app/models/style_guide/ruby"
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

    style_checker = StyleChecker.new([stylish_file, violated_file])

    expect(style_checker.violations).to eq [expected]
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
