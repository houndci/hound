require "rails_helper"

describe StyleGuide::CoffeeScript do
  include ConfigurationHelper

  describe "enabled?" do
    context "with legacy coffee_script key" do
      it "is not enabled" do
        commit = double("Commit", file_content: <<-EOS.strip_heredoc)
          coffee_script:
            enabled: false
        EOS
        repo_config = RepoConfig.new(commit)
        style_guide = build_style_guide(repo_config: repo_config)

        expect(style_guide).not_to be_enabled
      end
    end

    context "with coffeescript key" do
      it "is not enabled" do
        commit = double("Commit", file_content: <<-EOS.strip_heredoc)
          coffeescript:
            enabled: false
        EOS
        repo_config = RepoConfig.new(commit)
        style_guide = build_style_guide(repo_config: repo_config)

        expect(style_guide).not_to be_enabled
      end
    end
  end

  describe "#file_review" do
    it "returns a saved and completed file review" do
      style_guide = build_style_guide
      file = build_file("foo")

      result = style_guide.file_review(file)

      expect(result).to be_persisted
      expect(result).to be_completed
    end

    context "with default configuration" do
      context "for long line" do
        it "returns file review with violations" do
          style_guide = build_style_guide
          file = build_file("1" * 81)

          violations = style_guide.file_review(file).violations
          violation = violations.first

          expect(violations.size).to eq 1
          expect(violation.filename).to eq "test.coffee"
          expect(violation.patch_position).to eq 2
          expect(violation.line_number).to eq 1
          expect(violation.messages).to match_array(
            ["Line exceeds maximum allowed length"]
          )
        end
      end

      context "for trailing whitespace" do
        it "returns file review with violation" do
          expect(violations_in("1   ").first).to match(/trailing whitespace/)
        end
      end

      context "for inconsistent indentation" do
        it "returns file review with violation" do
          code = <<-CODE.strip_heredoc
            class FooBar
              foo: ->
                  "bar"
          CODE

          expect(violations_in(code)).to be_any { |m| m =~ /inconsistent/ }
        end
      end

      context "for non-PascalCase classes" do
        it "returns file review with violation" do
          result = violations_in("class strange_ClassNAME")

          expect(result).to be_any { |m| m =~ /camel cased/ }
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

    context "thoughtbot pull request" do
      it "uses the default thoughtbot configuration" do
        spy_on_coffee_lint
        spy_on_file_read
        config_file = thoughtbot_configuration_file(StyleGuide::CoffeeScript)

        violations_in("var foo = 'bar'", repository_owner_name: "thoughtbot")

        expect(File).to have_received(:read).with(config_file)
        expect(Coffeelint).to have_received(:lint).
          with(anything, thoughtbot_configuration)
      end
    end

    context "non-thoughtbot pull request" do
      it "uses the default hound configuration" do
        spy_on_coffee_lint
        spy_on_file_read
        config_file = default_configuration_file(StyleGuide::CoffeeScript)

        violations_in("var foo = 'bar'", repository_owner_name: "foo")

        expect(File).to have_received(:read).
          with(config_file)
        expect(Coffeelint).to have_received(:lint).
          with(anything, default_configuration)
      end
    end

    context "given a `coffee.erb` file" do
      it "lints the file" do
        style_guide = build_style_guide
        file = build_file("class strange_ClassNAME", "test.coffee.erb")

        violations = style_guide.file_review(file).violations
        violation = violations.first

        expect(violations.size).to eq 1
        expect(violation.filename).to eq "test.coffee.erb"
        expect(violation.messages).to match_array(
          ["Class names should be camel cased"]
        )
      end

      it "removes the ERB tags from the file" do
        style_guide = build_style_guide
        content = "leonidasLastWords = <%= raise 'hell' %>"
        file = build_file(content, "test.coffee.erb")

        violations = style_guide.file_review(file).violations

        expect(violations).to be_empty
      end
    end

    private

    def violations_in(content, repository_owner_name: "ralph")
      build_style_guide(repository_owner_name: repository_owner_name).
        file_review(build_file(content)).
        violations.
        flat_map(&:messages)
    end

    def build_file(content, filename = "test.coffee")
      build_commit_file(filename: filename, content: content)
    end

    def default_configuration
      config_file = default_configuration_file(StyleGuide::CoffeeScript)
      config = File.read(config_file)
      JSON.parse(config)
    end

    def thoughtbot_configuration
      config_file = thoughtbot_configuration_file(StyleGuide::CoffeeScript)
      config = File.read(config_file)
      JSON.parse(config)
    end

    def spy_on_coffee_lint
      allow(Coffeelint).to receive(:lint).and_return([])
    end
  end

  def build_style_guide(
    repo_config: default_repo_config,
    repository_owner_name: "RalphJoe"
  )
    StyleGuide::CoffeeScript.new(
      repo_config: repo_config,
      build: build(:build),
      repository_owner_name: repository_owner_name,
    )
  end

  def default_repo_config
    double("RepoConfig", enabled_for?: true, for: {})
  end
end
