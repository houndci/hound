require "coffeelint"
require "jshintrb"
require "rubocop"

require "fast_spec_helper"
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
    commit = stub_commit(files: [stylish_file, violated_file])
    expected_violations =
      ['Space inside parentheses detected.', 'Trailing whitespace detected.']

    violation_messages = StyleChecker.new(commit, stub_repo_config).violations.
      flat_map(&:messages)

    expect(violation_messages).to eq expected_violations
  end

  context "for a Ruby file" do
    context "with violations" do
      it "returns violations" do
        file = stub_commit_file("ruby.rb", "puts 123    ")
        commit = stub_commit(files: [file])

        violations = StyleChecker.new(commit, stub_repo_config).violations
        messages = violations.flat_map(&:messages)

        expect(messages).to eq ["Trailing whitespace detected."]
      end
    end

    context "with violation on unchanged line" do
      it "returns no violations" do
        file = stub_commit_file("foo.rb", "'wrong quotes'", UnchangedLine.new)
        commit = stub_commit(files: [file])

        violations = StyleChecker.new(commit, stub_repo_config).violations

        expect(violations.count).to eq 0
      end
    end

    context "without violations" do
      it "returns no violations" do
        file = stub_commit_file("ruby.rb", "puts 123")
        commit = stub_commit(files: [file])

        violations = StyleChecker.new(commit, stub_repo_config).violations
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
          file = stub_commit_file("test.coffee", "foo: ->")
          commit = stub_commit(
            files: [file],
            file_content: config
          )

          violations = StyleChecker.new(commit, stub_repo_config).violations
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
          file = stub_commit_file("test.coffee", "alert 'Hello World'")
          commit = stub_commit(
            file_content: config,
            files: [file],
          )

          violations = StyleChecker.new(commit, stub_repo_config).violations

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
          file = stub_commit_file("test.coffee", "alert('Hello World')")
          commit = stub_commit(
            file_content: config,
            files: [file],
          )

          violations = StyleChecker.new(commit, stub_repo_config).violations

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
          file = stub_commit_file("test.js", "var test = 'test'")
          commit = stub_commit(
            file_content: config,
            files: [file],
          )

          violations = StyleChecker.new(commit, stub_repo_config).violations
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
          file = stub_commit_file("test.js", "var test = 'test'")
          commit = stub_commit(
            file_content: config,
            files: [file],
          )
          repo_config = RepoConfig.new(commit)

          violations = StyleChecker.new(commit, repo_config).violations

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
          file = stub_commit_file("test.js", "var test = 'test';")
          commit = stub_commit(
            file_content: config,
            files: [file],
          )

          violations = StyleChecker.new(commit, stub_repo_config).violations
          messages = violations.flat_map(&:messages)

          expect(messages).not_to include "Missing semicolon."
        end
      end
    end
  end

  context "with unsupported file type" do
    it "uses unsupported style guide" do
      file = stub_commit_file("fortran.f", %{PRINT *, "Hello World!"\nEND})
      commit = stub_commit(files: [file])

      violations = StyleChecker.new(commit, stub_repo_config).violations

      expect(violations).to eq []
    end
  end

  private

  def stub_repo_config(options = {})
    double("RepoConfig", { enabled_for?: true, for: {} }.merge(options))
  end

  def stub_commit(options = {})
    double("Commit", { file_content: "", files: [] }.merge(options))
  end

  def stub_commit_file(filename, contents, line = nil)
    line ||= Line.new(content: "foo", number: 1, patch_position: 2)
    formatted_contents = "#{contents}\n"
    double(
      filename.split(".").first,
      filename: filename,
      content: formatted_contents,
      removed?: false,
      line_at: line,
    )
  end
end
