require "attr_extras"
require "rubocop"
require "coffeelint"
require "fast_spec_helper"
require "active_support/core_ext"
require "app/models/style_checker"
require "app/models/violation"
require "app/models/repo_config"
Dir.glob("app/models/style_guide/*.rb", &method(:require))

describe StyleChecker, '#violations' do
  it "returns a collection of computed violations" do
    stylish_file = stub_modified_file("good.rb", "def good; end")
    violated_file = stub_modified_file("bad.rb", "def bad( a ); a; end  ")
    pull_request =
      stub_pull_request(pull_request_files: [stylish_file, violated_file])
    expected = Violation.new(
      violated_file.filename,
      violated_file.modified_line_at,
      ['Space inside parentheses detected.', 'Trailing whitespace detected.']
    )

    style_checker = StyleChecker.new(pull_request)

    expect(style_checker.violations).to eq [expected]
  end

  context "when given a Ruby file" do
    it "returns violations" do
      file = stub_modified_file("ruby.rb", %{puts "Hello World" })
      pull_request = stub_pull_request(pull_request_files: [file])

      violations = StyleChecker.new(pull_request).violations
      messages = violations.flat_map(&:messages)

      expect(messages).to eq ["Trailing whitespace detected."]
    end
  end

  context "when given a CoffeeScript file" do
    let(:file_content) { "alert 'Hello World'" }

    context "and is enabled out" do
      it "returns violations" do
        config = <<-YAML.strip_heredoc
          coffee_script:
            enabled: true
        YAML
        head_commit = double("Commit", file_content: config)
        file = stub_modified_file("test.coffee", file_content)
        pull_request = stub_pull_request(
          head_commit: head_commit,
          pull_request_files: [file],
        )

        violations = StyleChecker.new(pull_request).violations
        messages = violations.flat_map(&:messages)

        expect(messages).to eq ["Implicit parens are forbidden"]
      end
    end

    context "and CoffeeScript support is not enabled" do
      it "does not use CoffeeScript style guide" do
        file = stub_modified_file("test.coffee", file_content)
        pull_request = stub_pull_request(pull_request_files: [file])

        violations = StyleChecker.new(pull_request).violations

        expect(violations).to eq []
      end
    end
  end

  context "with unsupported file type" do
    it "uses unsupported style guide" do
      file = stub_modified_file("fortran.f", %{PRINT *, "Hello World!"\nEND})
      pull_request = stub_pull_request(pull_request_files: [file])

      violations = StyleChecker.new(pull_request).violations

      expect(violations).to eq []
    end
  end

  private

  def stub_pull_request(options = {})
    head_commit = double("Commit", file_content: "")
    defaults = {
      file_content: "",
      head_commit: head_commit,
      pull_request_files: [],
    }

    double("PullRequest", defaults.merge(options))
  end

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
