require 'rubocop'
require 'fast_spec_helper'
require 'app/models/style_checker'

describe StyleChecker, '#violations' do
  context 'when some files have violations' do
    it 'returns only the files with violations' do
      file1 = file_stub("def hi \n\tactive = true ")
      file2 = file_stub("def hello\nend\n")
      file3 = file_stub("class User  \nend\n")

      style_checker = StyleChecker.new([file1, file2, file3])
      violations = style_checker.violations

      expect(violations).to have(2).items
      expect(violations[0]).to have(2).line_violations
      expect(violations[0].line_violations[0]).to have(3).messages
      expect(violations[1]).to have(1).line_violations
    end

    it 'returns only one of each violation type' do
      file1 = file_stub("{ :first => 1, :second => 2 }\n")

      style_checker = StyleChecker.new([file1])
      violations = style_checker.violations

      expect(violations).to have(1).item
      expect(violations[0]).to have(1).line_violations
      expect(violations[0].line_violations[0]).to have(1).messages
    end
  end

  context 'when leading dots are used to break up method chains' do
    it 'finds violations' do
      file = file_stub(<<-CONTENT)
person
  .name
      CONTENT
      style_checker = StyleChecker.new([file])

      expect(style_checker).to have_at_least(1).violations
    end
  end

  context 'when trailing dots are used to break up method chains' do
    it 'does not find violations' do
      file = file_stub(<<-CONTENT)
person.
  name
      CONTENT
      style_checker = StyleChecker.new([file])

      expect(style_checker).to have(0).violations
    end
  end

  context 'when rules are violated' do
    it 'finds all violations' do
      file = file_stub(content_with_violations)
      style_checker = StyleChecker.new([file])

      violations = style_checker.violations

      violation_messages = violation_messages(violations)
      expect(violation_messages).to have(2).items
      expect(violation_messages[0]).to match(/parentheses/)
      expect(violation_messages[1]).to match(/single-quoted strings/)
    end

    context 'when custom configuration overrides quote rule' do
      it 'finds only one violation' do
        file = file_stub(content_with_violations)
        custom_config = <<-FILE
          StringLiterals:
            EnforcedStyle: double_quotes
            Enabled: true
        FILE
        style_checker = StyleChecker.new([file], custom_config)

        violations = style_checker.violations

        violation_messages = violation_messages(violations)
        expect(violation_messages).to have(1).items
        expect(violation_messages[0]).to match(/parentheses/)
        expect(violation_messages[0]).not_to match(/single-quoted strings/)
      end
    end

    def content_with_violations
      <<-EOL
        def test_method()
          "hello world"
        end
      EOL
    end
  end

  def file_stub(contents)
    double(
      filename: 'test_pr_file',
      contents: contents,
      relevant_line?: true
    ).as_null_object
  end

  def violation_messages(violations)
    violations.map(&:line_violations).flatten.map(&:messages).flatten
  end
end
