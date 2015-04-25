require "rails_helper"

describe StyleChecker, "#violations" do
  it "returns a collection of computed violations" do
    stylish_file = stub_commit_file("good.rb", "def good; end")
    violated_file = stub_commit_file("bad.rb", "def bad( a ); a; end  ")
    pull_request =
      stub_pull_request(pull_request_files: [stylish_file, violated_file])
    expected_violations = ["Unnecessary spacing detected.",
                           "Space inside parentheses detected.",
                           "Trailing whitespace detected."]

    violation_messages = StyleChecker.new(pull_request).violations.
      flat_map(&:messages)

    expect(violation_messages).to eq expected_violations
  end

  context "for a Ruby file" do
    context "with style violations" do
      it "returns violations" do
        file = stub_commit_file("ruby.rb", "puts 123    ")
        pull_request = stub_pull_request(pull_request_files: [file])

        violations = StyleChecker.new(pull_request).violations
        messages = violations.flat_map(&:messages)
        expected_violations = ["Unnecessary spacing detected.",
                               "Trailing whitespace detected."]

        expect(messages).to eq expected_violations
      end
    end

    context "with style violation on unchanged line" do
      it "returns no violations" do
        file = stub_commit_file("foo.rb", "'wrong quotes'", UnchangedLine.new)
        pull_request = stub_pull_request(pull_request_files: [file])

        violations = StyleChecker.new(pull_request).violations

        expect(violations.count).to eq 0
      end
    end

    context "without style violations" do
      it "returns no violations" do
        file = stub_commit_file("ruby.rb", "puts 123")
        pull_request = stub_pull_request(pull_request_files: [file])

        violations = StyleChecker.new(pull_request).violations
        messages = violations.flat_map(&:messages)

        expect(messages).to be_empty
      end
    end
  end

  context "for a CoffeeScript file" do
    it "is processed with a coffee.js extension" do
      file = stub_commit_file("test.coffee.js", "foo ->")
      pull_request = stub_pull_request(pull_request_files: [file])
      style_checker = StyleChecker.new(pull_request)
      allow(RepoConfig).to receive(:new).and_return(stub_repo_config)

      violations = style_checker.violations
      messages = violations.flat_map(&:messages)

      expect(messages).to eq ["Empty function"]
    end

    it "is processed with a coffee.erb extension" do
      file = stub_commit_file("test.coffee.erb", "class strange_ClassNAME")
      pull_request = stub_pull_request(pull_request_files: [file])
      style_checker = StyleChecker.new(pull_request)
      allow(RepoConfig).to receive(:new).and_return(stub_repo_config)

      violations = style_checker.violations
      messages = violations.flat_map(&:messages)

      expect(messages).to eq ["Class names should be camel cased"]
    end

    context "with style violations" do
      it "returns violations" do
        file = stub_commit_file("test.coffee", "foo: ->")
        pull_request = stub_pull_request(pull_request_files: [file])

        violations = StyleChecker.new(pull_request).violations
        messages = violations.flat_map(&:messages)

        expect(messages).to eq ["Empty function"]
      end
    end

    context "without style violations" do
      it "returns no violations" do
        file = stub_commit_file("test.coffee", "alert('Hello World')")
        pull_request = stub_pull_request(pull_request_files: [file])

        violations = StyleChecker.new(pull_request).violations

        expect(violations).to be_empty
      end
    end
  end

  context "for a JavaScript file" do
    context "with style violations" do
      it "returns violations" do
        file = stub_commit_file("test.js", "var test = 'test'")
        pull_request = stub_pull_request(pull_request_files: [file])

        violations = StyleChecker.new(pull_request).violations
        messages = violations.flat_map(&:messages)

        expect(messages).to include "Missing semicolon."
      end
    end

    context "without style violations" do
      it "returns no violations" do
        file = stub_commit_file("test.js", "var test = 'test';")
        pull_request = stub_pull_request(pull_request_files: [file])

        violations = StyleChecker.new(pull_request).violations
        messages = violations.flat_map(&:messages)

        expect(messages).not_to include "Missing semicolon."
      end
    end

    context "an excluded file" do
      it "returns no violations" do
        config = <<-YAML.strip_heredoc
          javascript:
            ignore_file: '.jshintignore'
        YAML

        head_commit = stub_head_commit(
          ".hound.yml" => config,
          ".jshintignore" => "test.js"
        )

        file = stub_commit_file("test.js", "var test = 'test'")
        pull_request = stub_pull_request(
          head_commit: head_commit,
          pull_request_files: [file]
        )

        violations = StyleChecker.new(pull_request).violations

        expect(violations).to be_empty
      end
    end
  end

  context "for a SCSS file" do
    context "with style violations" do
      it "returns violations" do
        file = stub_commit_file(
          "test.scss",
          ".table p.inner table td { background: red; }"
        )
        pull_request = stub_pull_request(pull_request_files: [file])

        violations = StyleChecker.new(pull_request).violations
        messages = violations.flat_map(&:messages)

        expect(messages).to include(
          "Selector should have depth of applicability no greater than 2, but was 4"
        )
      end
    end

    context "without style violations" do
      it "returns no violations" do
        file = stub_commit_file("test.scss", "table td { color: green; }")
        pull_request = stub_pull_request(pull_request_files: [file])

        violations = StyleChecker.new(pull_request).violations
        messages = violations.flat_map(&:messages)

        expect(messages).not_to include(
          "Selector should have depth of applicability no greater than 3"
        )
      end
    end
  end

  context "with unsupported file type" do
    it "uses unsupported style guide" do
      file = stub_commit_file("fortran.f", %{PRINT *, "Hello World!"\nEND})
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
      repository_owner_name: "some_org"
    }

    double("PullRequest", defaults.merge(options))
  end

  def stub_commit_file(filename, contents, line = nil)
    line ||= Line.new(content: "foo", number: 1, patch_position: 2)
    formatted_contents = "#{contents}\n"
    double(
      filename.split(".").first,
      filename: filename,
      content: formatted_contents,
      line_at: line,
    )
  end

  def stub_head_commit(options)
    head_commit = double("Commit", file_content: nil)

    options.each do |filename, file_contents|
      allow(head_commit).to receive(:file_content).
        with(filename).and_return(file_contents)
    end

    head_commit
  end

  def stub_repo_config
    double(
      "RepoConfig",
      enabled_for?: true,
      for: {},
      ignored_javascript_files: []
    )
  end
end
