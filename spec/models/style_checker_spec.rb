require "coffeelint"
require "jshintrb"
require "rubocop"

require "fast_spec_helper"
require "app/models/default_config_file"
require "app/models/line"
require "app/models/unchanged_line"
require "app/models/repo_config"
require "app/models/style_checker"
require "app/models/violation"
require "app/models/violations"
Dir.glob("app/models/style_guide/*.rb", &method(:require))

describe StyleChecker, "#violations" do
  it "returns a collection of computed violations" do
    stylish_file = stub_commit_file("good.rb", "def good; end")
    violated_file = stub_commit_file("bad.rb", "def bad( a ); a; end  ")
    pull_request =
      stub_pull_request(pull_request_files: [stylish_file, violated_file])
    expected_violations =
      ['Space inside parentheses detected.', 'Trailing whitespace detected.']

    violation_messages = StyleChecker.new(pull_request).violations.
      flat_map(&:messages)

    expect(violation_messages).to eq expected_violations
  end

  context "for a Ruby file" do
    context "with violations" do
      it "returns violations" do
        file = stub_commit_file("ruby.rb", "puts 123    ")
        pull_request = stub_pull_request(pull_request_files: [file])

        violations = StyleChecker.new(pull_request).violations
        messages = violations.flat_map(&:messages)

        expect(messages).to eq ["Trailing whitespace detected."]
      end
    end

    context "with violation on unchanged line" do
      it "returns no violations" do
        file = stub_commit_file("foo.rb", "'wrong quotes'", UnchangedLine.new)
        pull_request = stub_pull_request(pull_request_files: [file])

        violations = StyleChecker.new(pull_request).violations

        expect(violations.count).to eq 0
      end
    end

    context "without violations" do
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
    context "with violations" do
      context "with CoffeeScript enabled" do
        it "returns violations" do
          config = <<-YAML.strip_heredoc
            coffee_script:
              enabled: true
          YAML
          head_commit = double("Commit", file_content: config)
          file = stub_commit_file("test.coffee", "foo: ->")
          pull_request = stub_pull_request(
            head_commit: head_commit,
            pull_request_files: [file],
          )

          violations = StyleChecker.new(pull_request).violations
          messages = violations.flat_map(&:messages)

          expect(messages).to eq ["Empty function"]
        end
      end

      context "with CoffeeScript disabled" do
        it "returns no violations" do
          config = <<-YAML.strip_heredoc
            coffee_script:
              enabled: false
          YAML
          head_commit = double("Commit", file_content: config)
          file = stub_commit_file("test.coffee", "alert 'Hello World'")
          pull_request = stub_pull_request(
            head_commit: head_commit,
            pull_request_files: [file],
          )

          violations = StyleChecker.new(pull_request).violations

          expect(violations).to be_empty
        end
      end
    end

    context "without violations" do
      context "with CoffeeScript enabled" do
        it "returns no violations" do
          config = <<-YAML.strip_heredoc
            coffee_script:
              enabled: true
          YAML
          head_commit = double("Commit", file_content: config)
          file = stub_commit_file("test.coffee", "alert('Hello World')")
          pull_request = stub_pull_request(
            head_commit: head_commit,
            pull_request_files: [file],
          )

          violations = StyleChecker.new(pull_request).violations

          expect(violations).to be_empty
        end
      end
    end
  end

  context "for a JavaScript file" do
    context "with violations" do
      context "with JavaScript enabled" do
        it "returns violations" do
          config = <<-YAML.strip_heredoc
            java_script:
              enabled: true
          YAML
          head_commit = double("Commit", file_content: config)
          file = stub_commit_file("test.js", "var test = 'test'")
          pull_request = stub_pull_request(
            head_commit: head_commit,
            pull_request_files: [file],
          )

          violations = StyleChecker.new(pull_request).violations
          messages = violations.flat_map(&:messages)

          expect(messages).to include "Missing semicolon."
        end
      end

      context "with JavaScript disabled" do
        it "returns no violations" do
          config = <<-YAML.strip_heredoc
            java_script:
              enabled: false
          YAML
          head_commit = double("Commit", file_content: config)
          file = stub_commit_file("test.js", "var test = 'test'")
          pull_request = stub_pull_request(
            head_commit: head_commit,
            pull_request_files: [file],
          )

          violations = StyleChecker.new(pull_request).violations

          expect(violations).to be_empty
        end
      end
    end

    context "without violations" do
      context "with JavaScript enabled" do
        it "returns no violations" do
          config = <<-YAML.strip_heredoc
            java_script:
              enabled: true
          YAML
          head_commit = double("Commit", file_content: config)
          file = stub_commit_file("test.js", "var test = 'test';")
          pull_request = stub_pull_request(
            head_commit: head_commit,
            pull_request_files: [file],
          )

          violations = StyleChecker.new(pull_request).violations
          messages = violations.flat_map(&:messages)

          expect(messages).not_to include "Missing semicolon."
        end
      end
    end

    context "an excluded file" do
      it "returns no violations" do
        config = <<-YAML.strip_heredoc
          java_script:
            enabled: true
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

  context "with unsupported file type" do
    it "uses unsupported style guide" do
      file = stub_commit_file("fortran.f", %{PRINT *, "Hello World!"\nEND})
      pull_request = stub_pull_request(pull_request_files: [file])

      violations = StyleChecker.new(pull_request).violations

      expect(violations).to eq []
    end
  end

  context "a removed file" do
    it "does not return a violation for the file" do
      file = stub_commit_file("ruby.rb", "puts 123    ", removed: true)
      pull_request = stub_pull_request(pull_request_files: [file])

      violations = StyleChecker.new(pull_request).violations
      messages = violations.flat_map(&:messages)

      expect(messages).to eq []
    end
  end

  private

  def stub_pull_request(options = {})
    head_commit = double("Commit", file_content: "")
    defaults = {
      file_content: "",
      head_commit: head_commit,
      pull_request_files: [],
      repository_owner: "some_org"
    }

    double("PullRequest", defaults.merge(options))
  end

  def stub_commit_file(filename, contents, line = nil, removed: false)
    line ||= Line.new(content: "foo", number: 1, patch_position: 2)
    formatted_contents = "#{contents}\n"
    double(
      filename.split(".").first,
      filename: filename,
      content: formatted_contents,
      removed?: removed,
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
end
