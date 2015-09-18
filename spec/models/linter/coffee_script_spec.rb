require "rails_helper"

describe Linter::CoffeeScript do
  include ConfigurationHelper

  describe ".can_lint?" do
    context "given a .coffee file" do
      it "returns true" do
        result = Linter::CoffeeScript.can_lint?("foo.coffee")

        expect(result).to eq true
      end
    end

    context "given a .coffee.erb file" do
      it "returns true" do
        result = Linter::CoffeeScript.can_lint?("foo.coffee.erb")

        expect(result).to eq true
      end
    end

    context "given a .coffee.js file" do
      it "returns true" do
        result = Linter::CoffeeScript.can_lint?("foo.coffee.js")

        expect(result).to eq true
      end
    end

    context "given a non-coffee file" do
      it "returns false" do
        result = Linter::CoffeeScript.can_lint?("foo.js")

        expect(result).to eq false
      end
    end
  end

  describe "enabled?" do
    context "with legacy coffee_script key" do
      it "is not enabled" do
        commit = double("Commit", file_content: <<-EOS.strip_heredoc)
          coffee_script:
            enabled: false
        EOS
        repo_config = RepoConfig.new(commit)
        linter = build_linter(repo_config: repo_config)

        expect(linter).not_to be_enabled
      end
    end

    context "with coffeescript key" do
      it "is not enabled" do
        commit = double("Commit", file_content: <<-EOS.strip_heredoc)
          coffeescript:
            enabled: false
        EOS
        repo_config = RepoConfig.new(commit)
        linter = build_linter(repo_config: repo_config)

        expect(linter).not_to be_enabled
      end
    end
  end

  describe "#file_review" do
    it "returns a saved and completed file review" do
      linter = build_linter
      file = build_file("foo")

      result = linter.file_review(file)

      expect(result).to be_persisted
      expect(result).to be_completed
    end

    context "with default configuration" do
      context "for long line" do
        it "returns file review with violations" do
          linter = build_linter
          file = build_file("1" * 81)

          violations = linter.file_review(file).violations
          violation = violations.first

          expect(violation.line_number).to eq 1
          expect(violation.messages).to(
            include("Line exceeds maximum allowed length")
          )
        end
      end
    end

    context "with custom configuration" do
      context "when line length is configured" do
        it "does not find line length violation" do
          repo_config = double(
            "RepoConfig",
            enabled_for?: true,
            for: {
              "max_line_length": {
                "value": 81
              }
            }
          )
          linter = build_linter(repo_config: repo_config)
          file = build_file("1" * 81)

          violations = linter.file_review(file).violations

          messages = violations.flat_map(&:messages)
          expect(messages).not_to include("Line exceeds maximum allowed length")
        end
      end
    end

    context "with violation on unchanged line" do
      it "finds no violations" do
        file = double(
          :file,
          content: "'hello'",
          filename: "lib/test.coffee",
          line_at: nil,
        )

        violations = violations_in(file)

        expect(violations.count).to eq 0
      end
    end

    context "given a `coffee.erb` file" do
      it "lints the file" do
        linter = build_linter
        file = build_file("class strange_ClassNAME", "test.coffee.erb")

        violations = linter.file_review(file).violations
        violation = violations.first

        expect(violation.line_number).to eq 1
        expect(violation.messages).to(
          include("Class name should be UpperCamelCased")
        )
      end

      it "removes the ERB tags from the file" do
        linter = build_linter
        content = "leonidasLastWords = <%= raise 'hell' %>"
        file = build_file(content, "test.coffee.erb")

        violations = linter.file_review(file).violations

        expect(violations).to be_empty
      end
    end

    private

    def violations_in(content, repository_owner_name: "ralph")
      build_linter(repository_owner_name: repository_owner_name).
        file_review(build_file(content)).
        violations.
        flat_map(&:messages)
    end

    def build_file(content, filename = "test.coffee")
      build_commit_file(filename: filename, content: content)
    end
  end

  def build_linter(
    repo_config: default_repo_config,
    repository_owner_name: "RalphJoe"
  )
    Linter::CoffeeScript.new(
      repo_config: repo_config,
      build: build(:build),
      repository_owner_name: repository_owner_name,
    )
  end

  def default_repo_config
    double("RepoConfig", enabled_for?: true, for: {})
  end
end
