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
        style_guide = StyleGuide::CoffeeScript.new(repo_config, "RalphJoe")

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
        style_guide = StyleGuide::CoffeeScript.new(repo_config, "RalphJoe")

        expect(style_guide).not_to be_enabled
      end
    end
  end

  describe "#violations_in_file" do
    context "with default configuration" do
      context "for long line" do
        it "returns violation" do
          repo_config = double("RepoConfig", enabled_for?: true, for: {})
          style_guide = StyleGuide::CoffeeScript.new(repo_config, "Ralph")
          file = double(
            :file,
            content: "1" * 81,
            filename: "test.coffee",
          )

          violations = style_guide.violations_in_file(file)
          violation = violations.first

          expect(violations.size).to eq 1
          expect(violation.filename).to eq "test.coffee"
          expect(violation.line_number).to eq 1
          expect(violation.messages).to match_array(
            ["Line exceeds maximum allowed length"]
          )
        end
      end

      context "for trailing whitespace" do
        it "returns violation" do
          expect(violations_in("1   ").first).to match(/trailing whitespace/)
        end
      end

      context "for inconsistent indentation" do
        it "returns violation" do
          code = <<-CODE.strip_heredoc
            class FooBar
              foo: ->
                  "bar"
          CODE

          expect(violations_in(code)).to be_any { |m| m =~ /inconsistent/ }
        end
      end

      context "for non-PascalCase classes" do
        it "returns violation" do
          result = violations_in("class strange_ClassNAME")

          expect(result).to be_any { |m| m =~ /camel cased/ }
        end
      end
    end

    context "thoughtbot pull request" do
      it "uses the default thoughtbot configuration" do
        spy_on_coffee_lint
        spy_on_file_read
        config_file = thoughtbot_configuration_file(StyleGuide::CoffeeScript)

        violations_in("var foo = 'bar'", repository_owner_name: "thoughtbot")

        expect(File).to have_received(:read).
          with(config_file)
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
        repo_config = double("RepoConfig", enabled_for?: true, for: {})
        style_guide = StyleGuide::CoffeeScript.new(repo_config, "Ralph")
        line = double("Line", content: "blah", number: 1, patch_position: 2)
        file = double(
          "File",
          content: "class strange_ClassNAME",
          filename: "test.coffee.erb",
          line_at: line
        )

        violations = style_guide.violations_in_file(file)
        violation = violations.first

        expect(violations.size).to eq 1
        expect(violation.filename).to eq "test.coffee.erb"
        expect(violation.line_number).to eq 1
        expect(violation.messages).to match_array(
          ["Class names should be camel cased"]
        )
      end

      it "removes the ERB tags from the file" do
        repo_config = double("RepoConfig", enabled_for?: true, for: {})
        style_guide = StyleGuide::CoffeeScript.new(repo_config, "Ralph")
        line = double("Line", content: "blah", number: 1, patch_position: 2)
        file = double(
          "File",
          content: "leonidasLastWords = <%= raise 'hell' %>",
          filename: "test.coffee.erb",
          line_at: line,
        )

        violations = style_guide.violations_in_file(file)

        expect(violations).to be_empty
      end
    end

    private

    def violations_in(content, repository_owner_name: "ralph")
      repo_config = double("RepoConfig", enabled_for?: true, for: {})
      style_guide = StyleGuide::CoffeeScript.new(
        repo_config,
        repository_owner_name
      )
      style_guide.violations_in_file(build_file(content)).flat_map(&:messages)
    end

    def build_file(content)
      filename = "test.coffee"
      patch_body = ""
      PullRequestFile.new(filename, content, patch_body)
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
end
