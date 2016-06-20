require "rails_helper"

describe Linter::Rubocop do
  describe ".can_lint?" do
    context "given a .rb file" do
      it "returns true" do
        result = Linter::Rubocop.can_lint?("foo.rb")

        expect(result).to eq true
      end
    end

    context "given a non-ruby file" do
      it "returns false" do
        result = Linter::Rubocop.can_lint?("foo.js")

        expect(result).to eq false
      end
    end
  end

  describe "#file_review" do
    include ConfigurationHelper

    it "returns a saved and completed file review" do
      stub_ruby_config
      linter = build_linter(build: build_with_stubbed_owner_config(""))

      result = linter.file_review(build_file("test"))

      expect(result).to be_persisted
      expect(result).to be_completed
    end

    context "with default rubocop config" do
      it "returns no violations for code with the lonely operator" do
        code = "user.subscription&.amount\n"

        violations = violations_in(code)

        expect(violations).to eq []
      end

      context "for private prefix" do
        it "returns no violations" do
          code = <<~CODE
            private def foo
              bar
            end
          CODE

          violations = violations_in(code)

          expect(violations).to eq []
        end
      end

      context "for trailing commas" do
        it "returns no violations" do
          code = <<-CODE.strip_heredoc
            _one = [
              1
            ]
            _two(
              1
            )
            _three = {
              one: 1
            }
          CODE

          violations = violations_in(code)

          expect(violations).to eq []
        end
      end

      context "when using detect" do
        it "returns no violations" do
          code = "users.detect(&:active?)\n"

          violations = violations_in(code)

          expect(violations).to eq []
        end
      end

      context "when using select" do
        it "returns no violations" do
          code = "users.select(&:active?)\n"

          violations = violations_in(code)

          expect(violations).to eq []
        end
      end

      context "when using map" do
        it "returns no violations" do
          code = "users.map(&:active?)\n"

          violations = violations_in(code)

          expect(violations).to eq []
        end
      end

      context "when using inject" do
        it "returns no violations" do
          code = <<~CODE
            users.inject(0) do |sum, user|
              sum + user.age
            end
          CODE

          violations = violations_in(code)

          expect(violations).to eq []
        end
      end

      context "for long line" do
        it "returns violation" do
          expected_violations = ["Line is too long. [81/80]"]
          code = "a" * 81 + "\n"

          violations = violations_in(code)

          expect(violations).to eq expected_violations
        end
      end

      context "for trailing whitespace" do
        it "returns violation" do
          expected_violations = ["Trailing whitespace detected."]
          code = "[1, 2].sum \n"

          violations = violations_in(code)

          expect(violations).to eq expected_violations
        end
      end

      context "for spaces after (" do
        it "returns violations" do
          expected_violations = ["Space inside parentheses detected."]
          code = "logger( 'test')\n"

          violations = violations_in(code)

          expect(violations).to eq expected_violations
        end
      end

      context "for spaces before )" do
        it "returns violations" do
          expected_violations = ["Space inside parentheses detected."]
          code = "logger('test' )\n"

          violations = violations_in(code)

          expect(violations).to eq expected_violations
        end
      end

      context "for spaces before ]" do
        it "returns violations" do
          expected_violations = ["Space inside square brackets detected."]
          code = "a['test' ]\n"

          violations = violations_in(code)

          expect(violations).to eq expected_violations
        end
      end

      context "for private methods indented more than public methods" do
        it "returns violations" do
          expected_violations = ["Inconsistent indentation detected."]
          code = <<~CODE
            def one
              1
            end

            private

              def two
                2
              end
          CODE

          violations = violations_in(code)

          expect(violations).to eq expected_violations
        end
      end

      context "for tab indentation" do
        it "returns violations" do
          expected_violations = [
            "Use 2 (not 1) spaces for indentation.",
            "Tab detected."
          ]
          code = <<~CODE
            def test
            \tlogger 'test'
            end
          CODE

          violations = violations_in(code)

          expect(violations).to eq expected_violations
        end
      end

      context "for two methods without newline separation" do
        it "returns violations" do
          expected_violations = ["Use empty lines between method definitions."]
          code = <<~CODE
            def one
              1
            end
            def two
              2
            end
          CODE

          violations = violations_in(code)

          expect(violations).to eq(expected_violations)
        end
      end

      context "for operator without surrounding spaces" do
        it "returns violations" do
          expected_violation = "Surrounding space missing for operator `+`."
          code = "two = 1+1\n"

          violations = violations_in(code)

          expect(violations).to include expected_violation
        end
      end

      context "for comma without trailing space" do
        it "returns violations" do
          expected_violations = ["Space missing after comma."]
          code = "logger :one,:two\n"

          violations = violations_in(code)

          expect(violations).to eq expected_violations
        end
      end

      context "for colon without trailing space" do
        it "returns violations" do
          expected_violations = [
            "Space missing after colon.",
            "Space inside { missing.",
            "Space inside } missing.",
          ]
          code = "{one:1}\n"

          violations = violations_in(code)

          expect(violations).to eq expected_violations
        end
      end

      context "for is_* method name" do
        it "returns violations" do
          expected_violations = ["Rename `is_something?` to `something?`."]
          code = <<~CODE
            def is_something?
              'something'
            end
          CODE

          violations = violations_in(code)

          expect(violations).to eq expected_violations
        end
      end

      context "for semicolon without trailing space" do
        it "returns violations" do
          expected_violations = [
            "Do not use semicolons to terminate expressions.",
            "Space missing after semicolon.",
          ]
          code = "logger :one;logger :two\n"

          violations = violations_in(code)

          expect(violations).to eq expected_violations
        end
      end

      context "for opening brace without leading space" do
        it "returns violations" do
          expected_violations = ["Surrounding space missing for operator `=`."]
          code = <<~CODE
            a ={ one: 1 }
            a
          CODE

          violations = violations_in(code)

          expect(violations).to eq expected_violations
        end
      end

      context "for opening brace without trailing space" do
        it "returns violations" do
          expected_violations = ["Space inside { missing."]
          code = <<~CODE
            a = {one: 1 }
            a
          CODE

          violations = violations_in(code)

          expect(violations).to eq expected_violations
        end
      end

      context "for closing brace without leading space" do
        it "returns violations" do
          expected_violations = ["Space inside } missing."]
          code = <<~CODE
            a = { one: 1}
            a
          CODE

          violations = violations_in(code)

          expect(violations).to eq expected_violations
        end
      end

      context "for method definitions with optional named arguments" do
        it "does not return violations" do
          code = <<~CODE
            def register_email(email:)
              register(email)
            end
          CODE

          violations = violations_in(code)

          expect(violations).to eq []
        end
      end

      context "for argument list spanning multiple lines" do
        context "when each argument is not on its own line" do
          it "returns violations" do
            expected_violations = [
              "Align the parameters of a method call if they span more than " \
                "one line.",
            ]
            code = <<~CODE
              validates :name,
                presence: true,
                uniqueness: true
            CODE

            violations = violations_in(code)

            expect(violations).to eq expected_violations
          end
        end

        context "when each argument is on its own line" do
          it "returns no violations" do
            code = <<~CODE
              validates(
                :name,
                presence: true,
                uniqueness: true
              )
            CODE

            violations = violations_in(code)

            expect(violations).to eq []
          end
        end
      end

      context "for required keyword arguments" do
        context "without space after arguments" do
          it "returns no violations" do
            code = <<~CODE
              def initialize(name:, age:)
                @name = name
                @age = age
              end
            CODE

            violations = violations_in(code)

            expect(violations).to eq []
          end
        end

        context "with spaces after arguments" do
          it "returns violations" do
            expected_violations = [
              "Space found before comma.",
              "Space inside parentheses detected.",
            ]
            code = <<~CODE
              def initialize(name: , age: )
                @name = name
                @age = age
              end
            CODE

            violations = violations_in(code)

            expect(violations).to eq expected_violations
          end
        end
      end

      context "with using block" do
        it "returns violations" do
          expected_violations = ["Pass `&:name` as an argument to `map` "\
                        "instead of a block."]
          code = <<~CODE
            users.map do |user|
              user.name
            end
          CODE

          violations = violations_in(code)

          expect(violations).to eq expected_violations
        end
      end

      context "with calls debugger" do
        it "returns violations" do
          expected_violations = ["Remove debugger entry point `binding.pry`."]
          code = "binding.pry\n"

          violations = violations_in(code)

          expect(violations).to eq expected_violations
        end
      end

      context "with empty lines around block" do
        it "returns violations" do
          expected_violations = [
            "Extra empty line detected at block body beginning.",
            "Extra empty line detected at block body end.",
          ]
          code = <<~CODE
            block do |hoge|

              hoge

            end
          CODE

          violations = violations_in(code)

          expect(violations).to eq expected_violations
        end
      end

      context "with unnecessary space" do
        it "returns violations" do
          expected_violations = [
            "Unnecessary spacing detected.",
            "Operator `=` should be surrounded by a single space.",
          ]
          code = <<~CODE
            hoge  = 'https://github.com/bbatsov/rubocop'
            hoge
          CODE

          violations = violations_in(code)

          expect(violations).to eq expected_violations
        end
      end
    end

    context "with legacy hound configuration set on owner" do
      context "for single line conditional" do
        it "returns no violations" do
          code = "if signed_in? then redirect_to dashboard_path end\n"

          violations = legacy_violations_in(code)

          expect(violations).to eq []
        end
      end

      context "for has_* method name" do
        it "returns no violations" do
          code = <<~CODE
            def has_something?
              "something"
            end
          CODE

          violations = legacy_violations_in(code)

          expect(violations).to eq []
        end
      end

      context "when using find" do
        it "returns violations" do
          expected_violations = ["Prefer `detect` over `find`."]
          code = "users.find(&:active?)\n"

          violations = legacy_violations_in(code)

          expect(violations).to eq expected_violations
        end
      end

      context "when using find_all" do
        it "returns violations" do
          expected_violations = ["Prefer `select` over `find_all`."]
          code = "users.find_all(&:active?)\n"

          violations = legacy_violations_in(code)

          expect(violations).to eq expected_violations
        end
      end

      context "when using collect" do
        it "returns violations" do
          expected_violations = ["Prefer `map` over `collect`."]
          code = "users.collect(&:active?)\nusers.collect(&:active?)\n"

          violations = legacy_violations_in(code)

          expect(violations).to eq expected_violations
        end
      end

      context "when using reduce" do
        it "returns violations" do
          expected_violations = ["Prefer `inject` over `reduce`."]
          code = <<~CODE
            users.reduce(0) do |_, user|
              user.age
            end
          CODE

          violations = legacy_violations_in(code)

          expect(violations).to eq expected_violations
        end
      end

      context "for leading dot used for multi-line method chain" do
        it "returns violations" do
          expected_violations = [
            "Place the . on the previous line, together with the "\
            "method call receiver.",
          ]
          code = <<~CODE
            one
              .two
          CODE

          violations = legacy_violations_in(code)

          expect(violations).to eq expected_violations
        end
      end

      context "when continued lines are not aligned with operand" do
        it "returns violations" do
          expected_violations = [
            "Align `limit` with `User.order(:name).` on line 2.",
          ]
          code = <<-CODE.strip_heredoc
            def user_names
              user = User.order(:name).
                limit(10)
              user.pluck(:name)
            end
          CODE

          violations = legacy_violations_in(code)

          expect(violations).to eq expected_violations
        end
      end
    end

    context "with thoughtbot configuration set on owner" do
      context "when continued lines are aligned with operand" do
        it "returns violations" do
          expected_violations = [
            "Use 2 (not 7) spaces for indenting an expression " \
              "in an assignment spanning multiple lines.",
          ]
          code = <<-CODE.strip_heredoc
            def foo
              user = User.where(email: "user@example.com").
                     assign_attributes(name: "User")
              user.save!
            end
          CODE

          violations = thoughtbot_violations_in(code)

          expect(violations).to eq expected_violations
        end
      end

      context "when using reduce" do
        it "returns no violations" do
          code = <<~CODE
            users.reduce(0) do |sum, user|
              sum + user.age
            end
          CODE

          violations = thoughtbot_violations_in(code)

          expect(violations).to eq []
        end
      end

      context "when using inject" do
        it "returns violations" do
          expected_violations = ["Prefer `reduce` over `inject`."]
          code = <<-CODE.strip_heredoc
            users.inject(0) do |_, user|
              user.age
            end
          CODE

          violations = thoughtbot_violations_in(code)

          expect(violations).to eq expected_violations
        end
      end

      context "when ommitting trailing commas" do
        it "returns violations" do
          expected_violations = [
            "Put a comma after the last item of a multiline hash.",
          ]
          code = <<-CODE.strip_heredoc
            {
              a: 1,
              b: 2
            }
          CODE

          violations = thoughtbot_violations_in(code)

          expect(violations).to eq expected_violations
        end
      end

      context "when trailing commas are present" do
        it "returns no violations" do
          code = <<~CODE
            {
              a: 1,
              b: 2,
            }
          CODE

          violations = thoughtbot_violations_in(code)

          expect(violations).to eq []
        end
      end
    end

    context "with custom configuration" do
      it "finds only one violation" do
        expected_violations = ["Use the new Ruby 1.9 hash syntax."]
        config = stub_ruby_config(
          "StringLiterals" => {
            "EnforcedStyle" => "double_quotes",
          },
        )
        code = <<-CODE.strip_heredoc
          { :foo => 'hello world' }
        CODE

        violations = violations_in(code, config: config)

        expect(violations).to eq expected_violations
      end

      it "can use custom configuration to display rubocop cop names" do
        expected_violations = [
          "Style/HashSyntax: Use the new Ruby 1.9 hash syntax.",
        ]
        config = stub_ruby_config(
          "AllCops" => { "DisplayCopNames" => "true" },
        )
        code = <<-CODE.strip_heredoc
          { :foo => 'hello world' }
        CODE

        violations = violations_in(code, config: config)

        expect(violations).to eq expected_violations
      end

      context "with old-style syntax" do
        it "has one violation" do
          expected_violations = [
            "Prefer single-quoted strings when you don't need string "\
            "interpolation or special symbols.",
          ]
          config = stub_ruby_config(
            "Style/StringLiterals" => {
              "EnforcedStyle" => "single_quotes",
            },
            "Style/HashSyntax" => {
              "EnforcedStyle" => "hash_rockets",
            },
          )
          code = <<~CODE
            { :foo => "hello world" }
          CODE

          violations = violations_in(code, config: config)

          expect(violations).to eq expected_violations
        end
      end
    end

    context "with inline configuration" do
      context "disabling a cop" do
        it "does not return a violation" do
          config = stub_ruby_config(
            "Style/StringLiterals" => {
              "EnforcedStyle" => "double_quotes",
            },
          )
          code = <<-CODE.strip_heredoc
            # rubocop:disable Style/StringLiterals
            'hello world'
          CODE

          violations = violations_in(code, config: config)

          expect(violations).to eq []
        end
      end
    end
  end

  describe "#file_included?" do
    context "with excluded file" do
      it "returns false" do
        stub_ruby_config("AllCops" => { "Exclude" => ["ignore.rb"] })
        file = double("CommitFile", filename: "ignore.rb")
        linter = build_linter(build: build_with_stubbed_owner_config(""))

        expect(linter.file_included?(file)).to eq false
      end
    end

    context "with included file" do
      it "returns true" do
        stub_ruby_config("AllCops" => { "Exclude" => [] })
        file = double("CommitFile", filename: "app.rb")
        linter = build_linter(build: build_with_stubbed_owner_config(""))

        expect(linter.file_included?(file)).to eq true
      end
    end
  end

  private

  def build_with_stubbed_owner_config(config)
    stub_commit_on_repo(
      repo: "organization/style",
      sha: "HEAD",
      files: {
        ".hound.yml" => <<~EOF,
          rubocop:
            config_file: .rubocop.yml
        EOF
        ".rubocop.yml" => config,
      },
    )
    owner = build(
      :owner,
      config_enabled: true,
      config_repo: "organization/style",
    )
    repo = build(:repo, owner: owner)
    build(:build, repo: repo)
  end

  def violations_in(content, config: "{}")
    linter = build_linter(build: build_with_stubbed_owner_config(config))

    linter.
      file_review(build_file(content)).
      violations.
      flat_map(&:messages)
  end

  def legacy_violations_in(content)
    config = File.open("spec/support/fixtures/legacy_rubocop_config.yml")
    violations_in(content, config: config)
  end

  def thoughtbot_violations_in(content)
    config = File.open("spec/support/fixtures/thoughtbot_rubocop_config.yml")
    violations_in(content, config: config)
  end

  def build_linter(build:, hound_config: build_hound_config)
    Linter::Rubocop.new(hound_config: hound_config, build: build)
  end

  def stub_ruby_config(config = {})
    stubbed_ruby_config = double("RubocopConfig", content: config)
    allow(Config::Rubocop).to receive(:new).and_return(stubbed_ruby_config)

    stubbed_ruby_config
  end

  def build_hound_config
    double(
      "HoundConfig",
      enabled_for?: true,
      content: { "rubocop" => { "enabled" => true } },
    )
  end

  def build_file(content)
    build_commit_file(filename: "app/models/user.rb", content: content)
  end
end
