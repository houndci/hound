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
    context "when configuration is enabled" do
      it "is enabled" do
        hound_config = double("HoundConfig", enabled_for?: true)
        linter = build_linter(hound_config: hound_config)

        expect(linter).to be_enabled
      end
    end

    context "when the config has enabled_for to false" do
      it "is not enabled" do
        hound_config = double("HoundConfig", enabled_for?: false)
        linter = build_linter(hound_config: hound_config)

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

          expect(result).to eq(["Class name should be UpperCamelCased"])
        end
      end
    end

    context "with thoughtbot configuration" do
      context "for an empty function" do
        it "returns a file review without violations" do
          code = <<-CODE.strip_heredoc
            class FooBar
              foo: ->
          CODE

          violations = violations_in(code, repository_owner_name: "thoughtbot")

          expect(violations).to be_empty
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
        config_file = thoughtbot_configuration_file(Linter::CoffeeScript)

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
        config_file = default_configuration_file(Linter::CoffeeScript)

        violations_in("var foo = 'bar'", repository_owner_name: "foo")

        expect(File).to have_received(:read).
          with(config_file)
        expect(Coffeelint).to have_received(:lint).
          with(anything, default_configuration)
      end
    end

    context "given a `coffee.erb` file" do
      it "lints the file" do
        linter = build_linter
        file = build_file("class strange_ClassNAME", "test.coffee.erb")

        violations = linter.file_review(file).violations
        violation = violations.first

        expect(violations.size).to eq 1
        expect(violation.filename).to eq "test.coffee.erb"
        expect(violation.messages).to match_array [
          "Class name should be UpperCamelCased",
        ]
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

    def default_configuration
      config_file = default_configuration_file(Linter::CoffeeScript)
      config = File.read(config_file)
      JSON.parse(config)
    end

    def thoughtbot_configuration
      config_file = thoughtbot_configuration_file(Linter::CoffeeScript)
      config = File.read(config_file)
      JSON.parse(config)
    end

    def spy_on_coffee_lint
      allow(Coffeelint).to receive(:lint).and_return([])
    end
  end

  def build_linter(
    hound_config: default_hound_config,
    config: stub_coffeescript_config,
    repository_owner_name: "RalphJoe"
  )
    config
    Linter::CoffeeScript.new(
      hound_config: hound_config,
      build: build(:build),
      repository_owner_name: repository_owner_name,
    )
  end

  def stub_coffeescript_config(content: {}, excluded_files: [])
    config = double(
      "CoffeeScriptConfig",
      content: content,
      excluded_files: excluded_files,
    )
    allow(Config::CoffeeScript).to receive(:new).and_return(config)
    config
  end

  def default_hound_config
    double("HoundConfig", enabled_for?: true, content: {})
  end
end
